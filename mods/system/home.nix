{pkgs, ...}: {
  programs.fuse.userAllowOther = true;
  home-manager.backupFileExtension = "backup";

  environment.systemPackages = with pkgs; [
    home-manager
  ];
}
