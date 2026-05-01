_: {
  # Core Imports
  imports = [
    ./filesystem.nix
    ./hardware.nix
    ./wifi.nix
  ];

  # Secrets
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHX8xYUGCFSnNC2LfioaQUD1E4QVzLTAcAvlOo7dB110 root@pc-anders";

  # Feature Suites
  my.profiles.developer.enable = true;
  my.profiles.desktop.enable = true;
  my.profiles.gaming.enable = true;

  # Options
  nixpkgs.config.allowUnfree = true;
  my.impermanence.enable = true;
  my.impermanence.extraDirs = [];

  # System maintenance
  my.autoUpgrade = {
    enable = true;
    flake = "github:munkien/nixos#pc-anders";
  };

  # Network
  networking.networkmanager.enable = true;
  networking.useNetworkd = false;
  services.resolved.enable = false;

  # Naming
  networking.hostName = "pc-anders";

  # Sleep and hibernation
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
