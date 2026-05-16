{
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    # Base ISO profiles
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
    "${modulesPath}/profiles/all-hardware.nix"
  ];

  # Allow proprietary firmware and handle unfree packages
  nixpkgs.config.allowUnfree = true;

  # --- HARDWARE & KERNEL BOOT FIXES ---
  # Using the standard stable kernel package to avoid unstable/LTS alias issues
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [
    "acpi=copy_dsdt" # Workaround for BIOS ACPI table limits
    "nvme_core.default_ps_max_latency_us=0" # Prevents NVMe drive hangs
    "nomodeset" # Basic video output to avoid driver crashes
    "pcie_aspm=off" # Disables active state power management
    "console=ttyS0,115200n8" # Enable serial console
    "console=tty0"
  ];

  users.users.nixos.initialPassword = "nixos";

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  # FORCE REMOVAL OF ZFS: This bypasses the 'broken package' evaluation error
  boot.supportedFilesystems = lib.mkForce ["ext4" "btrfs" "bcachefs" "ntfs" "vfat"];

  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;

  # --- REMOTE ACCESS & AUTH ---
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "yes";
  };

  # Automatically log in to the physical console
  services.getty.autologinUser = "nixos";

  # Update with your actual public key for remote rescue
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHBrIzRbUZF4n3SuvZHjzuFv+8vfQrS7Yvov+hjGWJ1 munkien@pc-anders.home.arpa"
  ];

  # --- NETWORKING ---
  networking.hostName = "rescue";
  networking.networkmanager.enable = true;

  # --- SYSTEM TOOLS ---
  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.systemPackages = with pkgs; [
    nixos-install-tools
    rsync
    gparted
    testdisk
    bcachefs-tools
    btrfs-progs
    smartmontools
    ntfs3g
    nvme-cli
    pciutils
    usbutils
    iperf3
    ethtool
    lm_sensors
    flashrom
    vim
    git
    htop
    btop
    wireguard-tools
    vscodium
  ];

  # ISO Optimization
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";
}
