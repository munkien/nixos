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

  services.smartd.enable = !config.virtualisation.hypervGuest.enable;

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

  users.users.root.hashedPassword = "$y$jFT$CiCF1yexMhqJzwW93W.tA1$Ta0ur3NW9HmlhDaDkHFh8sXK7e.6axUYY4GJjk4J0V4";

  system.stateVersion = "25.11";
}
