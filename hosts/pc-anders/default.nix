{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware.nix
    ./filesystem.nix
    ./wifi.nix

    ../../modules/common/desktop.nix
    ../../modules/common/gaming.nix
    ../../modules/common/impermanence.nix
  ];

  networking.hostName = "pc-anders";
  age.rekey.hostPubkey = lib.strings.trim (builtins.readFile ./hostPubkey.pub);

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "26.05";
}
