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

    ../../modules/services/mosquitto.nix
    ../../modules/services/caddy.nix
    ../../modules/services/frigate.nix
  ];

  networking.hostName = "pc-anders";
  age.rekey.hostPubkey = lib.strings.trim (builtins.readFile ./hostPubkey.pub);

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 60;

  #services.frigate.vaapiDriver = "radeonsi";
}
