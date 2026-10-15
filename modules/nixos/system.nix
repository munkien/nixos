{pkgs, ...}: {
  services = {
    journald.extraConfig = ''
      SystemMaxUse=200M
      MaxFileSec=14day
    '';

    locate = {
      enable = true;
      package = pkgs.plocate;
      interval = "hourly";
    };

    tuned = {
      enable = true;
      settings.dynamic_tuning = true;
    };
  };

  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableUserSlices = true;
    enableSystemSlice = true;
  };

  # Required for tmpfs root: /etc is ephemeral, so imperatively created users or
  # changed passwords would be lost on reboot. All accounts are declared in Nix
  # and use hashedPasswordFile / hashedPassword (see users/munkien/default.nix).
  # Guarded by the `stateless-root-requires-immutable-users` assertion.
  users = {
    mutableUsers = false;
    users.root.hashedPassword = "$y$jFT$G4A4efQj5fPKiajbtllMI.$0.ejwCo57NJ5Vw0plf9lK9cIp3rVIeqfMKwZeJCDUXD";
  };

  systemd.services.systemd-machine-id-commit.enable = false;
}
