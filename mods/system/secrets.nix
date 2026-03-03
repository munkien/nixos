{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${pkgs.system}.default
    age
    age-plugin-tpm
    ssh-to-age
    mkpasswd
  ];
}
