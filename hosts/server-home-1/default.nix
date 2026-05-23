{pkgs, ...}: {
  imports = [
    ./filesystem.nix
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  age.rekey.hostPubkey = "PASTE_YOUR_HOST_PUBKEY_HERE";

  # Sleep and hibernation
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Naming
  networking.hostName = "server-home-1";
}
