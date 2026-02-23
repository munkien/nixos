{ config, lib, pkgs, ... }:

{
  sops = {
    # 1. Cleaner pathing: Points to the specific host's secrets
    defaultSopsFile = ../../hosts/${config.networking.hostName}/secrets.yaml;
    
    # 2. Define the identity file (no auto-generation for TPM)
    age.keyFile = "/persist/secrets/age-tpm-identity.txt";
    age.generateKey = false;

    # 3. Fallback: Optional SSH key integration
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # 4. Critical: Ensure the TPM plugin is available for decryption at boot
  systemd.services.sops-nix.path = [ pkgs.age-plugin-tpm ];

  # 5. Tools for the shell
  environment.systemPackages = with pkgs; [
    sops
    age
    age-plugin-tpm
  ];
}
