{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    wget
    comma
    rustscan
    btop
    fastfetch
    ncdu
    trippy
    pwgen
  ];
}
