_: {
  fileSystems."/persist".neededForBoot = true;
  users.mutableUsers = false;

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        "/home/munkien/nixos"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/bluetooth"
        "/var/lib/systemd/timers"
        "/var/lib/tailscale"
        "/etc/ssh"
      ];

      files = [
        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/etc/adjtime-id";
          inInitrd = true;
        }
      ];
    };
  };
}
