{...}: {
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

  boot.tmp.useTmpfs = true;
}
