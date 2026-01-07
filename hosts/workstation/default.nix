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
    ../../mods/system/impermanence.nix
    ../../mods/system/gaming.nix

    ../../users/munkien
  ];

  environment.systemPackages = with pkgs; [

  ];

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

  services.btrbk = {
    ioSchedulingClass = "idle";
    niceness = 19;
    
    instances."local" = {
      onCalendar = "hourly";
      settings = {
        timestamp_format = "long-iso";
        preserve_day_of_week = "monday";
        preserve_hour_of_day = "0";
        snapshot_preserve_min = "6h";
        snapshot_preserve = "24h 7d 4w";

        volume."/persist" = {
          snapshot_dir = "/.snapshots/persist";
          subvolume = ".";
        };
      };
    };
  };
  
  systemd.tmpfiles.rules = [
    "d /.snapshots/persist 0700 root root -"
  ];

  networking.hostName = "workstation";
}
