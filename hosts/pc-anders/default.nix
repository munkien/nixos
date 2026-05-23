{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ./filesystem.nix
    ./wifi.nix
  ];

  networking.hostName = "pc-anders";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Host-specific decryption key
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1... replace-with-actual-host-key";

  system.stateVersion = "26.05";
}
