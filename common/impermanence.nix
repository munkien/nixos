_: {
  fileSystems."/persist".neededForBoot = true;
  users.mutableUsers = false;

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        {
          directory = "/home/munkien/nixos";
          user = "munkien";
          group = "users";
        }
        {
          directory = "/home/munkien/.ssh";
          user = "munkien";
          group = "users";
          mode = "0700";
        }

        "/var/lib/docker"
        "/var/lib/systemd/coredump"
        "/var/lib/bluetooth"
        "/var/lib/systemd/timers"
        "/var/lib/tailscale"
        "/var/log/journal"
        "/var/lib/containers"
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
          file = "/etc/ssh/ssh_host_ed25519_key.pub";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/machine-id";
          inInitrd = true;
        }
        {
          file = "/etc/adjtime";
          inInitrd = true;
        }
      ];
    };
  };
}
