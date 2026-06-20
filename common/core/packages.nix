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
  ];
}
