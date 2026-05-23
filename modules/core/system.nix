{
  config,
  pkgs,
  ...
}: {
  security.sudo.wheelNeedsPassword = false;
  programs.git.enable = true;

  programs.fuse.userAllowOther = true;
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "hourly";
  };

  services.smartd = {
    enable = !config.virtualisation.hypervGuest.enable;
    defaults.autodetected = "-a -o on -S on -n standby,q";
    notifications = {
      test = true;
      wall.enable = true;
    };
  };
  # Short Test Timer (Runs Daily)
  systemd.services.smart-test-short = {
    description = "Trigger Short SMART tests on all drives";
    path = [pkgs.smartmontools pkgs.gawk];
    script = ''
      smartctl --scan | awk '{print $1}' | while read -r disk; do
        smartctl -t short "$disk" || true
      done
    '';
    serviceConfig.Type = "oneshot";
  };
  systemd.timers.smart-test-short = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true; # If off, runs immediately on next boot
    };
  };
  # Long Test Timer (Runs Weekly)
  systemd.services.smart-test-long = {
    description = "Trigger Long SMART tests on all drives";
    path = [pkgs.smartmontools pkgs.gawk];
    script = ''
      smartctl --scan | awk '{print $1}' | while read -r disk; do
        smartctl -t long "$disk" || true
      done
    '';
    serviceConfig.Type = "oneshot";
  };
  systemd.timers.smart-test-long = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableUserSlices = true;
    enableSystemSlice = true;
  };

  services.tuned = {
    enable = true;
    settings.dynamic_tuning = true;
  };

  users.users.root.hashedPassword = "$y$jFT$G4A4efQj5fPKiajbtllMI.$0.ejwCo57NJ5Vw0plf9lK9cIp3rVIeqfMKwZeJCDUXD";

  system.stateVersion = "26.05";
}
