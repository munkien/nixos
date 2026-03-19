{pkgs, ...}: {
  programs.fuse.userAllowOther = true;
  home-manager.backupFileExtension = "backup";

  environment.systemPackages = with pkgs; [
    home-manager
  ];

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
}
