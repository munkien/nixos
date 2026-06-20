{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../common/core
    ../../users/munkien

    ./hardware.nix
    ./filesystem.nix
    ./wifi.nix

    ../../common/profiles/graphical/desktop.nix
    ../../common/profiles/graphical/gaming.nix
    ../../common/impermanence.nix
  ];

  my = {
    graphical.enable = true;
    gaming.enable = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

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

  systemd.services.systemd-machine-id-commit.enable = false;
  environment.etc."machine-id".text = "5f8c8eac5b85429fb8dc3d633e5b42e6";

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 60;
    };
    efi.canTouchEfiVariables = true;
  };
}
