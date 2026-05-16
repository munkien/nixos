{pkgs, ...}: {
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Options
  my.impermanence.enable = true;
  my.autoUpgrade = {
    enable = true;
    flake = "github:munkien/nixos#server-home-1";
  };

  # Sleep and hibernation
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Naming
  networking.hostName = "server-home-1";
}
