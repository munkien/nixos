# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
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

  # Style and wallpaper
  stylix = {
    enable = true;
    image = ./default-wallpaper.jpg;

    # https://github.com/tinted-theming/schemes
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono; # Ny syntax i unstable
        name = "JetBrainsMono Nerd Font";
      };
    };

    opacity.terminal = 0.9;
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

  # Wallpaper
  systemd.user.services.wallpaper-shuffler = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "download-walls" ''
        set -e

        WALLDIR="$HOME/.cache/wallpapers"
        mkdir -p "$WALLDIR"
        cd "$WALLDIR"

        FILE="wallpaper-$(date +%s).jpg"

        ${pkgs.curl}/bin/curl -L \
          "https://source.unsplash.com/3840x2160/?cyberpunk,technology" \
          -o "$FILE"

        # Keep only 10 newest wallpapers
        ls -tp | grep -v '/$' | tail -n +11 | xargs -r rm --

        # Reload wpaperd
        ${pkgs.procps}/bin/pkill -HUP wpaperd || true
      '';
    };
  };

  systemd.user.timers.wallpaper-shuffler = {
    timerConfig = {
      OnUnitActiveSec = "30m";
      RandomizedDelaySec = "1h";
      Persistent = true;
    };
    wantedBy = ["timers.target"];
  };

  # Swap Config
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };

  # Btrfs Vedligeholdelse
  services.btrfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = ["/"];
    };
  };

  networking.hostName = "workstation";
}
