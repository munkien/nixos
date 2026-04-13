{
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

  # Bootloader override
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    #device = "/dev/sda";
  };

  # Options
  my.impermanence.enable = true;
  my.autoUpgrade = {
    enable = true;
    flake = "github:munkien/nixos#server-datalix-1";
  };

  # Sleep and hibernation
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Naming
  networking.hostName = "server-datalix-1";
}
