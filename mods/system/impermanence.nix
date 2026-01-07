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
    ];
    files = [
      "/etc/machine-id"
      "/etc/shadow"
    ];
  };

  boot.initrd.systemd.services.rollback = {
    description = "Rollback Btrfs root subvolume to a pristine state";
    wantedBy = ["initrd.target"];
    after = ["dev-disk-by\x2dlabel-ROOT.device"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";

    script = ''
      mkdir -p /btrfs_tmp
      mount /dev/disk/by-label/ROOT /btrfs_tmp

      if [[ -e /btrfs_tmp/@ ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/$timestamp"
      fi

      btrfs subvolume create /btrfs_tmp/@

      umount /btrfs_tmp
    '';
  };
  systemd.services.btrfs-cleanup = {
    description = "Delete old Btrfs root subvolumes";
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    startAt = "daily"; # Kør en gang om dagen
    script = ''
      mkdir -p /btrfs_tmp
      mount /dev/disk/by-label/ROOT /btrfs_tmp

      # Older than 30 days
      find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30 | while read -r subvolume; do
        echo "Deleting old root: $subvolume"
        btrfs subvolume delete "$subvolume"
      done

      umount /btrfs_tmp
    '';
  };
}
