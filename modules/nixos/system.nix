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

  users.users.root.hashedPassword = "$y$jFT$G4A4efQj5fPKiajbtllMI.$0.ejwCo57NJ5Vw0plf9lK9cIp3rVIeqfMKwZeJCDUXD";
  systemd.services.systemd-machine-id-commit.enable = false;
}
