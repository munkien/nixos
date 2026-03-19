{pkgs, ...}: let
  bcachefs_device = "/dev/disk/by-id/wwn-0x50014ee267e93f2a:/dev/disk/by-id/wwn-0x50014ee2c089b39a-part1:/dev/disk/by-id/wwn-0x50014ee2086b9c3e:/dev/disk/by-id/wwn-0x50026b7258008b00:/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b444a48b3d6e5-part1:/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4d08dc78-part4"; # "/dev/disk/by-uuid/fe8de683-7e92-4cc0-ace2-8ce2bccfa296";
in {
  ##########
  # BOOT
  #########
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1D9E-C58C";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
    neededForBoot = true;
  };
  ##########
  # BCACHEFS MOUNT
  #########
  fileSystems."/mnt/bcachefs" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = [
      "noatime"
      "discard"
      "nofail"
    ];
    neededForBoot = true;
  };
  services.bcachefs.autoScrub.fileSystems = ["/mnt/bcachefs"];
  services.bcachefs.autoScrub.interval = "weekly";
  ##########
  # BCACHEFS BIND
  #########
  fileSystems."/scratch" = {
    device = "/mnt/bcachefs/@scratch";
    fsType = "none";
    options = ["bind" "nofail"];
    neededForBoot = false;
    depends = ["/mnt/bcachefs"];
  };
  fileSystems."/persist" = {
    device = "/mnt/bcachefs/@persist";
    fsType = "none";
    options = ["bind" "nofail"];
    neededForBoot = true;
    depends = ["/mnt/bcachefs"];
  };
  fileSystems."/var/log" = {
    device = "/mnt/bcachefs/@log";
    fsType = "none";
    options = ["bind" "nofail"];
    neededForBoot = true;
    depends = ["/mnt/bcachefs"];
  };
  fileSystems."/home" = {
    device = "/mnt/bcachefs/@home";
    fsType = "none";
    options = ["bind" "nofail"];
    neededForBoot = true;
    depends = ["/mnt/bcachefs"];
  };

  ##########
  # Impermanence
  #########
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=4G" "mode=755"];
    neededForBoot = true;
  };

  ##########
  # BTRFS
  #########
  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.fileSystems = ["/nix" "/.swap"];
  services.btrfs.autoScrub.interval = "weekly";

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/44c8f65e-0f9f-47f2-97aa-ddfadc0955c4";
    fsType = "btrfs";
    options = ["subvol=@nix" "compress=zstd" "noatime" "nofail"];
    neededForBoot = true;
  };

  fileSystems."/.swap" = {
    device = "/dev/disk/by-uuid/44c8f65e-0f9f-47f2-97aa-ddfadc0955c4";
    fsType = "btrfs";
    options = ["subvol=@swap" "noatime" "nofail"];
    neededForBoot = true;
  };

  system.activationScripts.bcachefs-infrastructure = {
    text = ''
      echo "bcachefs infrastructure"
      TOOL=${pkgs.bcachefs-tools}/bin/bcachefs
      POOL="/mnt/bcachefs"
      mkdir -p $POOL/{@scratch,@home,@persist,@nix,@log}

      $TOOL set-fs-option \
        --metadata_target=ssd \
        --metadata_replicas=2 \
        --errors=fix_safe \
        --compression=zstd \
        --background_compression=zstd \
        /dev/disk/by-uuid/fe8de683-7e92-4cc0-ace2-8ce2bccfa296 || true


      $TOOL set-file-option --data_replicas=1 --promote_target=ssd --foreground_target=hdd --background_target=hdd $POOL/@scratch || true
      $TOOL set-file-option --data_replicas=2 --promote_target=ssd --foreground_target=ssd --background_target=hdd $POOL/@home || true
      $TOOL set-file-option --data_replicas=2 --promote_target=ssd --foreground_target=ssd --background_target=hdd $POOL/@persist || true
      $TOOL set-file-option --data_replicas=2 --promote_target=ssd --foreground_target=ssd --background_target=ssd $POOL/@nix || true
      $TOOL set-file-option --data_replicas=1 --foreground_target=hdd --background_target=hdd $POOL/@log || true
    '';
  };
}
