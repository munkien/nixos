{lib, ...}: {
  # Bootloader override
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "virtio_net"
    "virtio_balloon"
    "virtio_ring"
  ];

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

  # Networking
  networking.useDHCP = false;
  networking.interfaces.ens18 = {
    ipv4.addresses = [
      {
        address = "37.114.41.97";
        prefixLength = 24;
      }
    ];
    ipv6.addresses = [
      {
        address = "2a0e:97c0:3ea:5b4::1";
        prefixLength = 64;
      }
    ];
  };
  networking.defaultGateway = "37.114.41.1";
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens18";
  };
}
