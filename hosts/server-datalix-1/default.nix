{lib, ...}: {
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

  # SSH allow root login
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  # Sleep and hibernation
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Naming
  networking.hostName = "server-datalix-1";
}
