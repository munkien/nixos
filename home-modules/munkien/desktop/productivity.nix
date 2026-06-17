{pkgs, ...}: {
  home.packages = with pkgs; [
    # Productivity
    libreoffice-qt-fresh

    # Privacy
    tor-browser
  ];
}
