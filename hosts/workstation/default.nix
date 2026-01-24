# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    ./filesystem.nix
    ./hardware.nix

    ../common.nix
    ../../mods/system/desktop.nix
    ../../mods/system/secrets.nix
    ../../mods/system/home.nix
    ../../mods/system/wifi-gl3.nix
    #../../mods/system/impermanence.nix
    ../../mods/system/gaming.nix

    ../../users/munkien
  ];

  environment.enableDebugInfo = true;
  environment.systemPackages = with pkgs; [
  ];

  services.jotta-cli.enable = true;

  # Vector Konfiguration
  sops.secrets.ntfy_url = {};
  systemd.services.vector.serviceConfig = {
    EnvironmentFile = config.sops.secrets.ntfy_url.path;
    SupplementaryGroups = ["systemd-journal"];
    DynamicUser = lib.mkForce false;
  };
  services.vector = {
    enable = true;
    journaldAccess = true;
    settings = {
      sources = {
        journald.type = "journald";
      };

      transforms = {
        filter_errors = {
          type = "filter";
          inputs = ["journald"];
          condition = ''to_int!(.PRIORITY) <= 3 && ._SYSTEMD_UNIT != "vector.service"'';
        };

        format_toast = {
          type = "remap";
          inputs = ["filter_errors"];
          source = ''
            message, err = string(.message)
            if err != null {
                message = "Ingen besked fundet"
            }
            . = "🚨 " + message
          '';
        };

        throttle_alerts = {
          type = "throttle";
          inputs = ["format_toast"];
          threshold = 1;
          window_secs = 60;
          key_field = ".";
        };
      };

      sinks.ntfy_sink = {
        type = "http";
        inputs = ["throttle_alerts"];
        uri = "https://ntfy.sh/xxxxxxxxxxx";
        method = "post";
        encoding.codec = "text";
      };
    };
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;

  specialisation = {
    "Recovery-Shell" = {
      configuration = {
        system.nixos.tags = ["recovery"];
        services.getty.autologinUser = "root";
        networking.hostName = lib.mkForce "nixos-recovery";
      };
    };
  };

  # Swap Config
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };

  networking.hostName = "workstation";
}
