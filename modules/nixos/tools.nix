{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wget
    rustscan
    btop
    fastfetch
    ncdu
    trippy
    pwgen
    gping
    trashy
    bcachefs-tools
    just
    e2fsprogs # chattr command
    libnotify
    kdePackages.kdialog
  ];
}
