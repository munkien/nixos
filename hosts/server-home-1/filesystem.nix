{
  pkgs,
  lib,
  ...
}: let
  bootUuid = "C1A0-38E8";
  sysUuid = "69147e59-47cc-40a0-8f7d-6da287866591";
  bcachefs_device = "/dev/disk/by-uuid/${sysUuid}";
in {
  boot.supportedFilesystems = ["bcachefs"];
  boot.initrd.supportedFilesystems = ["bcachefs"];

  ##########
  # BOOT (EFI)
  ##########
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/${bootUuid}";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
    neededForBoot = true;
  };

  ##########
  # BCACHEFS MASTER MOUNT (Poolen)
  ##########
  # Vi mounter selve partitionen ét sted først.
  fileSystems."/mnt/bcachefs" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = [
      "defaults"
      "noatime"
      "discard"
    ];
    neededForBoot = true;
  };

  # Aktiver automatisk scrub af dit bcachefs pool
  services.bcachefs.autoScrub.fileSystems = ["/mnt/bcachefs"];
  services.bcachefs.autoScrub.interval = "weekly";

  ##########
  # BCACHEFS BIND MOUNTS (Subvolumes/Mapper)
  ##########
  fileSystems."/nix" = {
    device = "/mnt/bcachefs/nix";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
    depends = ["/mnt/bcachefs"];
  };

  fileSystems."/persist" = {
    device = "/mnt/bcachefs/persist";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
    depends = ["/mnt/bcachefs"];
  };

  fileSystems."/var/log" = {
    device = "/mnt/bcachefs/log";
    fsType = "none";
    options = ["bind"];
    depends = ["/mnt/bcachefs"];
  };

  ##########
  # IMPERMANENCE (RAM disk)
  ##########
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=4G" "mode=755"];
    neededForBoot = true;
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
      mkdir -p $POOL/nix $POOL/persist $POOL/log

      # Sæt globale indstillinger for filsystemet
      $TOOL set-fs-option \
        --errors=fix_safe \
        --compression=lz4 \
        --background_compression=zstd \
        ${bcachefs_device} || true
    '';
  };
}
