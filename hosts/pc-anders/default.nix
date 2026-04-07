{
  config,
  pkgs,
  lib,
  ...
}: let
  users = ["munkien"];
in {
  home-manager.users = builtins.listToAttrs (map (u: {
      name = u;
      value = import ../../users/${u}/home.nix {inherit pkgs;};
    })
    users);

  # Options
  my.wifi.gl3.enable = true;
  my.impermanence.enable = true;
  my.impermanence.extraDirs = ["/var/lib/containers"];
  my.desktop.enable = true;
  my.autoUpgrade = {
    enable = true;
    flake = "github:munkien/nixos#pc-anders";
  };
  my.gaming.enable = true;

  # Services for testing
  my.containers.enable = true;
  my.services.frigate.enable = true;

  # Allow ventoy..
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];

  # Naming
  networking.hostName = "pc-anders";

  # Sleep and hibernation
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
