{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../nixos-modules/base-system.nix
    ../../home-modules/munkien

    ./hardware.nix
    ./filesystem.nix
    ./wifi.nix

    ../../nixos-modules/common/desktop.nix
    ../../nixos-modules/common/gaming.nix
    ../../nixos-modules/common/impermanence.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  isDesktop = true;
  isGaming = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.registries.search = ["docker.io" "quay.io"];
  environment.systemPackages = with pkgs; [
    podman-compose
  ];

  networking.hostName = "pc-anders";
  age.rekey.hostPubkey = lib.strings.trim (builtins.readFile ./hostPubkey.pub);

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 60;
    };
    efi.canTouchEfiVariables = true;
  };
}
