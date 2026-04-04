# modules/common/agenix.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  hasPersistence =
    config.environment ? persistence
    && config.environment.persistence ? "/persist";
  statePath =
    if hasPersistence
    then "/persist/etc/ssh"
    else "/etc/ssh";
in {
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${pkgs.system}.default
    age
    age-plugin-tpm
    ssh-to-age
    mkpasswd
  ];

  systemd.services.agenix = {
    after = ["basic.target"];
    requires = lib.optional hasPersistence "persist.mount";
    unitConfig.DefaultDependencies = false;
  };

  age.identityPaths = ["${statePath}/ssh_host_ed25519_key"];

  services.openssh.hostKeys = [
    {
      path = "${statePath}/ssh_host_rsa_key";
      type = "rsa";
      bits = 4096;
    }
    {
      path = "${statePath}/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  boot.initrd.secrets = lib.mkIf hasPersistence {
    "/etc/ssh/ssh_host_ed25519_key" = "/persist/etc/ssh/ssh_host_ed25519_key";
  };
}
