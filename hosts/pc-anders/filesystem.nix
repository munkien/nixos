{pkgs, ...}: let
  bcachefs_device = "UUID=fe8de683-7e92-4cc0-ace2-8ce2bccfa296";
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
      "degraded"
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
    options = ["bind"];
    neededForBoot = false;
    depends = ["/mnt/bcachefs"];
  };
  fileSystems."/persist" = {
    device = "/mnt/bcachefs/@persist";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
    depends = ["/mnt/bcachefs"];
  };
  fileSystems."/var/log" = {
    device = "/mnt/bcachefs/@log";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
    depends = ["/mnt/bcachefs"];
  };
  fileSystems."/home" = {
    device = "/mnt/bcachefs/@home";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
    depends = ["/mnt/bcachefs"];
  };
  fileSystems."/nix" = {
    device = "/mnt/bcachefs/@nix";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
    depends = ["/mnt/bcachefs"];
  };

  # BCachefs options
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
        --compression=lz4 \
        --background_compression=zstd \
        /dev/disk/by-uuid/fe8de683-7e92-4cc0-ace2-8ce2bccfa296 || true


      $TOOL set-file-option --data_replicas=1 --promote_target=ssd  --foreground_target=ssd --background_target=hdd $POOL/@scratch || true
      $TOOL set-file-option --data_replicas=2 --promote_target=ssd  --foreground_target=ssd --background_target=hdd $POOL/@home || true
      $TOOL set-file-option --data_replicas=2 --promote_target=ssd  --foreground_target=ssd --background_target=hdd $POOL/@persist || true
      $TOOL set-file-option --data_replicas=2 --promote_target=ssd  --foreground_target=ssd --background_target=ssd $POOL/@nix || true
      $TOOL set-file-option --data_replicas=1 --promote_target=none --foreground_target=hdd --background_target=hdd $POOL/@log || true
    '';
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
}
