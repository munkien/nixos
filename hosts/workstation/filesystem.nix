{
  lib,
  pkgs,
  ...
}: let
  bcachefs_device = "/dev/disk/by-uuid/fe8de683-7e92-4cc0-ace2-8ce2bccfa296";
in {
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1D9E-C58C";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };
  fileSystems."/mnt/bcachefs" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = ["noatime" "discard"];
  };
  fileSystems."/scratch" = {
    device = "/mnt/bcachefs/@scratch";
    options = ["bind" "nofail"];
    neededForBoot = false;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/44c8f65e-0f9f-47f2-97aa-ddfadc0955c4";
    fsType = "btrfs";
    options = ["subvol=@" "compress=zstd" "noatime"];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/44c8f65e-0f9f-47f2-97aa-ddfadc0955c4";
    fsType = "btrfs";
    options = ["subvol=@nix" "compress=zstd" "noatime"];
    neededForBoot = true;
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/44c8f65e-0f9f-47f2-97aa-ddfadc0955c4";
    fsType = "btrfs";
    options = ["subvol=@home" "compress=zstd" "noatime"];
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/44c8f65e-0f9f-47f2-97aa-ddfadc0955c4";
    fsType = "btrfs";
    options = ["subvol=@persist" "compress=zstd" "noatime"];
    neededForBoot = true;
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/44c8f65e-0f9f-47f2-97aa-ddfadc0955c4";
    fsType = "btrfs";
    options = ["subvol=@logs" "compress=zstd" "noatime"];
    neededForBoot = true;
  };

  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-uuid/44c8f65e-0f9f-47f2-97aa-ddfadc0955c4";
    fsType = "btrfs";
    options = ["subvol=@snapshots" "compress=zstd" "noatime"];
  };

  fileSystems."/.swap" = {
    device = "/dev/disk/by-uuid/44c8f65e-0f9f-47f2-97aa-ddfadc0955c4";
    fsType = "btrfs";
    options = ["subvol=@swap" "noatime"];
    neededForBoot = true;
  };

  system.activationScripts.bcachefs-infrastructure = {
    text = ''
      TOOL=${pkgs.bcachefs-tools}/bin/bcachefs
      POOL="/mnt/bcachefs"
      mkdir -p $POOL/{@scratch,@home,@persist,@nix}

      $TOOL set-fs-option --metadata_target=ssd --metadata_replicas=2 --errors=fix_safe --compression=zstd /dev/sda

      $TOOL set-file-option --data_replicas=1 --promote_target=ssd --foreground_target=hdd --background_target=hdd /scratch
      $TOOL set-file-option --data_replicas=2 --promote_target=ssd --foreground_target=ssd --background_target=hdd /home
      $TOOL set-file-option --data_replicas=2 --promote_target=ssd --foreground_target=ssd --background_target=hdd /persist
      $TOOL set-file-option --data_replicas=2 --promote_target=ssd --foreground_target=ssd --background_target=ssd /nix
    '';
  };
}
