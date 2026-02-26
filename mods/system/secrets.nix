{
  config,
  lib,
  pkgs,
  ...
}: {
  sops = {
    defaultSopsFile = ../../hosts/${config.networking.hostName}/secrets.yaml;

    age.keyFile = "/persist/secrets/age-tpm-identity.txt";
    age.generateKey = false;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };

  systemd.services.sops-nix.path = [pkgs.age-plugin-tpm];

  environment.systemPackages = with pkgs; [
    sops
    age
    age-plugin-tpm
  ];
}
