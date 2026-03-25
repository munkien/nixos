{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  # Check if persistence is enabled for "/persist"
  hasPersistence = config.environment ? persistence && config.environment.persistence ? "/persist";

  # Resolve the path: Use the persistent storage path if it exists, otherwise standard /etc/ssh
  statePath =
    if hasPersistence
    then config.environment.persistence."/persist".persistentStoragePath + "/etc/ssh"
    else "/etc/ssh";
in {
  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${pkgs.system}.default
    age
    age-plugin-tpm
    ssh-to-age
    mkpasswd
  ];

  # Only require persist.mount if persistence is actually active
  systemd.services.agenix = {
    after = ["basic.target"];
    requires = lib.optional hasPersistence "persist.mount";
    unitConfig.DefaultDependencies = false;
  };

  # Use the dynamic statePath for agenix identities
  age.identityPaths = [
    "${statePath}/ssh_host_ed25519_key"
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
      path = "${statePath}/ssh_host_rsa_key";
      type = "rsa";
      bits = 4096;
    }
    {
      path = "${statePath}/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];

  # Only attempt to load initrd secrets if we are using the persistence path
  # to avoid errors during build if the file doesn't exist at the target path.
  boot.initrd.secrets = lib.mkIf hasPersistence {
    "/etc/ssh/ssh_host_ed25519_key" = "/persist/etc/ssh/ssh_host_ed25519_key";
  };
}
