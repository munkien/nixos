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

  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
  ];
}
