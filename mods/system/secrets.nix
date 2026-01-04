{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  #sops.defaultSopsFile = ./nixos/secrets/common.yaml;
  sops.age = {
    sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];
    keyFile = "/persist/var/lib/sops-nix/key.txt";
    generateKey = true;
  };

  environment.systemPackages = with pkgs; [
    age
    sops
    pwgen
  ];
}
