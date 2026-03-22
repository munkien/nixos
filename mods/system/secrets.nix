{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  statePath = config.environment.persistence."/persist".persistentStoragePath + "/etc/ssh";
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

  services.openssh.hostKeys = [
    {
      path = statePath + "/ssh_host_rsa_key";
      type = "rsa";
      bits = 4096;
    }
    {
      path = statePath + "/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  boot.initrd.secrets = {
    "/etc/ssh/ssh_host_ed25519_key" = "/persist/etc/ssh/ssh_host_ed25519_key";
  };
}
