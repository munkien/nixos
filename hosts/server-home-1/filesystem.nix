{pkgs, ...}: let
  bootUuid = "C1A0-38E8";
  sysUuid = "69147e59-47cc-40a0-8f7d-6da287866591";
  bcachefs_device = "/dev/disk/by-uuid/${sysUuid}";
in {
  environment.systemPackages = with pkgs; [
    bcachefs-tools
    gparted
  ];

  boot = {
    supportedFilesystems = ["bcachefs"];
    initrd.supportedFilesystems = ["bcachefs"];
  };

  fileSystems = {
    # BOOT (EFI)
    "/boot" = {
      device = "/dev/disk/by-uuid/${bootUuid}";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
      neededForBoot = true;
    };

    # BCACHEFS MASTER MOUNT (Pool)
    # Vi mounter selve partitionen ét sted først.
    "/mnt/bcachefs" = {
      device = bcachefs_device;
      fsType = "bcachefs";
      options = [
        "defaults"
        "noatime"
        "discard"
      ];
      neededForBoot = true;
    };

    # BCACHEFS BIND MOUNTS (Subvolumes)
    "/nix" = {
      device = "/mnt/bcachefs/nix";
      fsType = "none";
      options = ["bind"];
      neededForBoot = true;
      depends = ["/mnt/bcachefs"];
    };

    "/persist" = {
      device = "/mnt/bcachefs/persist";
      fsType = "none";
      options = ["bind"];
      neededForBoot = true;
      depends = ["/mnt/bcachefs"];
    };

    "/var/log" = {
      device = "/mnt/bcachefs/log";
      fsType = "none";
      options = ["bind"];
      depends = ["/mnt/bcachefs"];
    };

    "/media" = {
      device = "/mnt/bcachefs/media";
      fsType = "none";
      options = ["bind"];
      depends = ["/mnt/bcachefs"];
    };

    # IMPERMANENCE (RAM disk)
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=4G" "mode=755"];
      neededForBoot = true;
    };
  };

  # Special rules for /media - no CoW
  systemd.tmpfiles.rules = [
    "d /mnt/bcachefs/media 0755 root root - -"
    "h /mnt/bcachefs/media - - - - +C"
  ];

  # Enable automatic scrub of bcachefs pool
  services.bcachefs.autoScrub = {
    fileSystems = ["/mnt/bcachefs"];
    interval = "weekly";
  };

  ##########
  # BCACHEFS INFRASTRUCTURE SCRIPT
  ##########
  # Sørger for at mapperne findes og sætter filsystem-indstillinger
  system.activationScripts.bcachefs-infrastructure = {
    text = ''
      echo "Konfigurerer bcachefs infrastruktur..."
      TOOL=${pkgs.bcachefs-tools}/bin/bcachefs
      POOL="/mnt/bcachefs"

      # Opret mapperne hvis de ikke findes på bcachefs
      mkdir -p $POOL/nix $POOL/persist $POOL/log $POOL/media

      # Routing
      bcachefs set-file-option --data_replicas=2 --promote_target=ssd --foreground_target=ssd --background_target=hdd $POOL/persist || true
      bcachefs set-file-option --data_replicas=2 --promote_target=ssd --foreground_target=ssd --background_target=ssd $POOL/nix || true
      bcachefs set-file-option --data_replicas=1 --promote_target=hdd --foreground_target=hdd --background_target=hdd $POOL/media || true

      # Sæt globale indstillinger for filsystemet
      $TOOL set-fs-option \
        --errors=fix_safe \
        --compression=lz4 \
        --background_compression=zstd \
        ${bcachefs_device} || true
    '';
  };
}
