_: {
  # Secrets
  age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHX8xYUGCFSnNC2LfioaQUD1E4QVzLTAcAvlOo7dB110 root@pc-anders";

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

  networking.networkmanager.enable = true;
  networking.useNetworkd = false;
  services.resolved.enable = false;

  boot.kernelParams = ["snd_hda_intel.power_save=0" "snd_hda_intel.power_save_controller=N"];

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
