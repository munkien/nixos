{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  environment.persistence."/persist" = {
    hideMounts = true; #
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/etc/adjtime"
      "/etc/ssh"
      "/etc/shadow"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  boot.initrd.systemd.services.rollback = {
    description = "Rollback Btrfs root subvolume to a pristine state";
    wantedBy = ["initrd.target"];
    after = ["cursor.target"]; # Sikrer at diskene er klar
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /mnt
      # Brug din disk-label fra Disko
      mount /dev/disk/by-label/ROOT /mnt

      if [[ -e /mnt/@ ]]; then
          mkdir -p /mnt/old_roots
          timestamp=$(date +%Y-%m-%d_%H-%M-%S)
          mv /mnt/@ "/mnt/old_roots/$timestamp"
      fi

      delete_old_roots() {
          find /mnt/old_roots/ -maxdepth 1 -mtime +30 | while read root; do
              btrfs subvolume delete "$root"
          done
      }
      delete_old_roots

      # Genskab fra det tomme snapshot
      btrfs subvolume snapshot /mnt/@blank /mnt/@
      umount /mnt
    '';
  };
}
