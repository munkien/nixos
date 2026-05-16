{lib, ...}: let
  bootUuid = "52A2-1526";
  sysUuid = "b8005c52-43ec-490a-9dde-328c7d617a61";
  storageVideoUuid = "d8d0ee41-7dc0-4fa7-ae8d-934f7549e186";
in {
  # Sikrer at bcachefs-tools er tilgængelige
  boot.supportedFilesystems = ["bcachefs"];

  # Impermanent Root på RAM (tmpfs)
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=2G"
      "mode=755"
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

  # Persistent Nix Store på bcachefs
  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/${sysUuid}";
    fsType = "bcachefs";
    # På bcachefs monterer vi subvolumes via 'subvol=' i options,
    # ligesom btrfs, forudsat de er oprettet korrekt.
    options = ["defaults" "subvol=nix"];
    neededForBoot = true;
  };

  # Persistent Data
  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/${sysUuid}";
    fsType = "bcachefs";
    options = ["defaults" "subvol=persist"];
    neededForBoot = true;
  };

  # Logs
  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/${sysUuid}";
    fsType = "bcachefs";
    options = ["defaults" "subvol=log"];
    neededForBoot = true;
  };

  # Storage disk (Hvis denne disk er bcachefs, ellers ret fsType tilbage til btrfs)
  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/${storageVideoUuid}";
    fsType = "bcachefs";
    options = ["defaults" "subvol=media" "nofail"];
  };

  # Da root er tmpfs, skal vi sikre at et machine-id kan genereres.
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir -p /mnt-root/etc
    touch /mnt-root/etc/machine-id
  '';
}
