{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical.nix>
  ];

  ############################################
  # Kernel & Filesystems
  ############################################

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = [
    "bcachefs"
    "btrfs"
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

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.initrd.systemd.enable = true;

  boot.plymouth.enable = true;

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
  # Live environment packages
  ############################################

  environment.systemPackages = with pkgs; [
    nixos-install-tools
    bcachefs-tools
    gparted
    ntfs3g
    vscodium
    vim
    git
  ];

  ############################################
  # Graphical Environment
  ############################################

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;

  ############################################
  # Networking
  ############################################

  networking.networkmanager.enable = true;

  ############################################
  # Locale
  ############################################

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "UTC";

  ############################################
  # ISO metadata
  ############################################

  isoImage.isoName = "nixos-bcachefs-installer.iso";
}
