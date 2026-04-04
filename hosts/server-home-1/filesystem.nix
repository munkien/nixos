{
  config,
  lib,
  pkgs,
  ...
}: let
  bootUuid = "52A2-1526";
  sysUuid = "b8005c52-43ec-490a-9dde-328c7d617a61";
  storageVideoUuid = "d8d0ee41-7dc0-4fa7-ae8d-934f7549e186";
in {
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [
      "/"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/${bootUuid}";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
    neededForBoot = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${sysUuid}";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
    neededForBoot = true;
  };

  fileSystems."/etc/nixos" = {
    device = "/dev/disk/by-uuid/${sysUuid}";
    fsType = "btrfs";
    options = [
      "subvol=nixos"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/${sysUuid}";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/${sysUuid}";
    fsType = "btrfs";
    options = [
      "subvol=persist"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
    neededForBoot = true;
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/${sysUuid}";
    fsType = "btrfs";
    options = [
      "subvol=log"
      "compress=zstd"
      "noatime"
    ];
    neededForBoot = true;
  };

  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/${storageVideoUuid}";
    fsType = "btrfs";
    options = [
      "subvol=media"
      "noatime"
      "nodiscard"
      "compress=none"
      "nodatacow"
      "nofail"
    ];
  };
}
