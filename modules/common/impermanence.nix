{...}: {
  fileSystems."/persist".neededForBoot = true;

  users.mutableUsers = false;

  environment.persistence."/persist" = {
    hideMounts = true;

    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/bluetooth"
      "/etc/ssh"
    ];

    files = [
      "/etc/machine-id"
      "/etc/adjtime"
    ];
  };
}
