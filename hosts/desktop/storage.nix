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

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/861a7672-36cc-4b08-9871-045de2aea527";
    fsType = "btrfs";
    options = ["subvol=@nix" "compress=zstd" "noatime" "discard=async"];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/861a7672-36cc-4b08-9871-045de2aea527";
    fsType = "btrfs";
    options = ["subvol=@persist" "compress=zstd" "noatime" "discard=async"];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1A85-5EA0";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };
  swapDevices = [];

  # Snapper!
  services.snapper.configs = {
    persist = {
      SUBVOLUME = "/persist";
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
    };
  };
  services.snapper.configs.persist.settings = {
    ALLOW_USERS = ["munkien"];
    TIMELINE_LIMIT_HOURLY = "10";
    TIMELINE_LIMIT_DAILY = "7";
    TIMELINE_LIMIT_WEEKLY = "0";
    TIMELINE_LIMIT_MONTHLY = "0";
    TIMELINE_LIMIT_YEARLY = "0";
  };
}
