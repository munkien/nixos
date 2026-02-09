{
  pkgs,
  ...
}: {
  sops.defaultSopsFile = ../../secrets.yaml;
  sops.age = {
    sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    keyFile = "/persist/secrets/age-tpm-identity.txt";
    generateKey = true;
  };

  environment.systemPackages = with pkgs; [
    age
    sops
    pwgen
    age-plugin-tpm
  ];
}
