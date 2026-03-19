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

  systemd.services.agenix = {
    after = ["persist.mount"];
    requires = ["persist.mount"];
    unitConfig.DefaultDependencies = false;
  };

  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
  ];

  virtualisation.vmVariant = {
    boot.initrd.secrets = lib.mkForce {};
    users.users.munkien = {
      password = "nixos";
      hashedPasswordFile = lib.mkForce null;
    };
  };

  boot.initrd.secrets = {
    "/etc/ssh/ssh_host_ed25519_key" = "/persist/etc/ssh/ssh_host_ed25519_key";
  };
}
