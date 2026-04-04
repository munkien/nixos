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

  networking.hostName = "usb-rescue-1";

  # ==========================================
  # Kernel & Filesystems
  # ==========================================
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = [
    "bcachefs"
    "btrfs"
    "vfat"
    "ext4"
    "ntfs3"
  ];

  # ==========================================
  # Initrd / Boot
  # ==========================================
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

  # ==========================================
  # Hardware
  # ==========================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # ==========================================
  # Live Environment Packages
  # ==========================================
  environment.systemPackages = with pkgs; [
    # Installation & Recovery
    nixos-install-tools
    rsync
    testdisk
    gparted
    # Disk & Filesystems
    bcachefs-tools
    btrfs-progs
    smartmontools
    nvme-cli
    ntfs3g
    # System Info & Network
    pciutils
    usbutils
    htop
    btop
    wireguard-tools
    # Editors & Dev
    vscodium
    vim
    git
  ];

  # ==========================================
  # SOPS / Secrets
  # ==========================================
  # Point this to wherever your encrypted yaml lives in your repo
  sops.defaultSopsFile = ../../secrets/rescue.yaml;
  sops.secrets."wifi-psk" = {};

  # Format the secret securely into a KEY=VALUE environment file
  sops.templates."wifi_password_1".content = ''
    WIFI_PASSWORD=${config.sops.placeholder."wifi-psk"}
  '';

  # ==========================================
  # Networking
  # ==========================================
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # Tell NetworkManager to read our secure template file
  networking.networkmanager.ensureProfiles.environmentFiles = [
    config.sops.templates."wifi_password_1".path
  ];

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
        # NetworkManager will expand this variable internally
        psk = "$WIFI_PASSWORD";
      };
    };
  };
}
