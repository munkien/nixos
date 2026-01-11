{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  sops.defaultSopsFile = ../../secrets.yaml;
  sops.age = {
    sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    keyFile = "/persist/var/lib/sops-nix/key.txt";
    generateKey = true;
  };

  environment.systemPackages = with pkgs; [
    age
    sops
    pwgen
  ];
}
