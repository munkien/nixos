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

  # 4. Critical: Ensure the TPM plugin is available for decryption at boot
  systemd.services.sops-nix.path = [pkgs.age-plugin-tpm];

  # 5. Tools for the shell
  environment.systemPackages = with pkgs; [
    sops
    age
    age-plugin-tpm
  ];
}
