{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  services.btrfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = ["/"];
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/861a7672-36cc-4b08-9871-045de2aea527";
    fsType = "btrfs";
    options = ["subvol=@" "compress=zstd" "noatime" "discard=async"];
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/861a7672-36cc-4b08-9871-045de2aea527";
    fsType = "btrfs";
    options = ["subvol=@snapshots" "compress=zstd" "noatime" "discard=async"];
  };

  /*
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/861a7672-36cc-4b08-9871-045de2aea527";
    fsType = "btrfs";
    options = ["subvol=@nix" "compress=zstd" "noatime" "discard=async"];
    neededForBoot = true;
  };
  */

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/861a7672-36cc-4b08-9871-045de2aea527";
    fsType = "btrfs";
    options = ["subvol=@persist" "compress=zstd" "noatime" "discard=async"];
    neededForBoot = true;
  };

  fileSystems."/home/munkien/nixos" = {
    device = "/persist/home/munkien/nixos";
    options = ["bind"];
  };

  fileSystems."/home/munkien/.ssh" = {
    device = "/persist/home/munkien/.ssh";
    options = ["bind"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1A85-5EA0";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/861a7672-36cc-4b08-9871-045de2aea527";
    fsType = "btrfs";
    options = ["subvol=@swap" "noatime" "nodatacow"];
    neededForBoot = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8192;
      priority = 0;
    }
  ];

  # Snapper!
  services.snapper.configs = {
    persist = {
      SUBVOLUME = "/.snapshots";
      ALLOW_USERS = ["munkien"];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;

      TIMELINE_LIMIT_HOURLY = "10";
      TIMELINE_LIMIT_DAILY = "7";
      TIMELINE_LIMIT_WEEKLY = "0";
      TIMELINE_LIMIT_MONTHLY = "0";
      TIMELINE_LIMIT_YEARLY = "0";
    };
  };
}
