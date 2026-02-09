{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    ../common.nix
  ];

  ############################################
  # Kernel & Filesystems
  ############################################

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = lib.mkForce [
    "bcachefs"
    "btrfs"
    "vfat"
    "ext4"
    "ntfs3"
  ];

  ############################################
  # Initrd / boot
  ############################################

  boot.initrd.availableKernelModules = [
    "nvme"
    "ahci"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  boot.initrd.kernelModules = ["amdgpu"];
  boot.initrd.systemd.enable = true;

  boot.kernelParams = [
    "nvme.max_host_mem_size_mb=64"
    "pcie_aspm=off"
    "usbcore.autosuspend=-1"
  ];

  ############################################
  # Hardware
  ############################################

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  ############################################
  # Authentication & More
  ############################################
  services.getty.autologinUser = "root";
  users.users.root.password = "";
  networking.wireless.enable = false;

  ############################################
  # Live environment packages
  ############################################

  environment.systemPackages = with pkgs; [
    # --- Installation & Recovery ---
    nixos-install-tools
    rsync
    testdisk

    # --- Disk & Filsystemer (Bcachefs fokus) ---
    bcachefs-tools
    btrfs-progs
    smartmontools
    nvme-cli
    gparted
    ntfs3g

    # --- System Info & Overvågning ---
    pciutils
    usbutils
    htop
    btop

    # --- Editorer & Udvikling ---
    vscodium
    vim
    git

    # --- Netværk ---
    wireguard-tools
  ];

  ############################################
  # Graphical Environment
  ############################################

  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;

  ############################################
  # Networking
  ############################################

  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles.profiles = {
    home-wifi = {
      connection = {
        id = "home-wifi";
        type = "wifi";
        autoconnect = true;
      };
      wifi = {
        mode = "infrastructure";
        ssid = "sild-paa-daase";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "";
      };
    };
  };
}
