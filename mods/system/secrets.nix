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
    age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];

    # Use the correct option to include the TPM plugin
    age.plugins = [pkgs.age-plugin-tpm];
  };

  # This ensures the plugin is available for the systemd service specifically
  systemd.services.sops-nix.path = [pkgs.age-plugin-tpm];

  environment.systemPackages = with pkgs; [
    sops
    age
    age-plugin-tpm
    ssh-to-age
  ];
}
