{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../users/munkien
    ./filesystem.nix

    # Services
    ../../common/services/arion.nix
    ../../common/services/caddy.nix
    ../../common/services/fail2ban.nix
    ../../common/services/frigate.nix
    ../../common/services/omada.nix
    ../../common/services/homeassistant.nix
    ../../common/services/authelia.nix
  ];

  hardware = {
    facter = {
      enable = true;
      reportPath = ./facter.json;
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  age.rekey.hostPubkey = lib.strings.trim (builtins.readFile ./hostPubkey.pub);

  # Sleep and hibernation
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  # Naming
  networking.hostName = "server-home-1";
}
