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

    smartd = {
      enable = !config.virtualisation.hypervGuest.enable;
      defaults.autodetected = "-a -o on -S on -n standby,q";
      notifications = {
        test = true;
        wall.enable = true;
      };
    };

    tuned = {
      enable = true;
      settings.dynamic_tuning = true;
    };
  };

  systemd = {
    # Short Test Timer (Runs Daily)
    services.smart-test-short = {
      description = "Trigger Short SMART tests on all drives";
      path = [pkgs.smartmontools pkgs.gawk];
      script = ''
        smartctl --scan | awk '{print $1}' | while read -r disk; do
          smartctl -t short "$disk" || true
        done
      '';
      serviceConfig.Type = "oneshot";
    };

    timers.smart-test-short = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true; # If off, runs immediately on next boot
      };
    };

    # Long Test Timer (Runs Weekly)
    services.smart-test-long = {
      description = "Trigger Long SMART tests on all drives";
      path = [pkgs.smartmontools pkgs.gawk];
      script = ''
        smartctl --scan | awk '{print $1}' | while read -r disk; do
          smartctl -t long "$disk" || true
        done
      '';
      serviceConfig.Type = "oneshot";
    };

    timers.smart-test-long = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };

    oomd = {
      enable = true;
      enableRootSlice = true;
      enableUserSlices = true;
      enableSystemSlice = true;
    };
  };

  system.stateVersion = "26.11";
}
