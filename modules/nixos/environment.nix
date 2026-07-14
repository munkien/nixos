{pkgs, ...}: {
  security.sudo.wheelNeedsPassword = false;
  programs.git.enable = true;
  programs.fuse.userAllowOther = true;

  environment = {
    pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];
  };
}
