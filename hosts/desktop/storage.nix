{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/861a7672-36cc-4b08-9871-045de2aea527";
    fsType = "btrfs";
    options = ["subvol=@"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/861a7672-36cc-4b08-9871-045de2aea527";
    fsType = "btrfs";
    options = ["subvol=@home"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1A85-5EA0";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];
}
