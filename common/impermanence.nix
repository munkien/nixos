{
  lib,
  config,
  ...
}: {
  fileSystems."/persist".neededForBoot = lib.mkIf (config.preservation.enable) true;
  users.mutableUsers = lib.mkIf (config.preservation.enable) true;

  preservation = {
    enable = lib.mkDefault true;
    preserveAt."/persist" = {
      directories = [
        "/var/lib/systemd/coredump"
        "/var/lib/bluetooth"
        "/var/lib/systemd/timers"
        "/var/lib/tailscale"
        "/var/log/journal"
        "/var/lib/nixos"
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
