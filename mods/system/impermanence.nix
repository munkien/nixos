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
    ];
  };

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    # Vi bruger labelen fra din disko.nix (ROOT)
    mount /dev/disk/by-label/ROOT /btrfs_tmp

    if [[ -e /btrfs_tmp/@ ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date +%Y-%m-%d_%H-%M-%S)
        mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/$timestamp"
    fi

    # Sletning af gamle roots (bemærk: rm -rf på btrfs subvols kan kræve 'btrfs subvolume delete')
    delete_old_roots() {
        find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30 | while read root; do
          btrfs subvolume delete "$root"
        done
    }
    delete_old_roots

    # Genskab fra det tomme snapshot vi definerede i disko.nix
    btrfs subvolume snapshot /btrfs_tmp/@blank /btrfs_tmp/@
    umount /btrfs_tmp
  '';
}
