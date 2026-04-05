{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
  ];

  networking.hostName = "usb-rescue-1";

  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles = {
    # Read the decrypted env file from the HOST machine and bake it into the ISO
    environmentFiles = [
      (pkgs.writeText "wifi-gl3-baked-env" (builtins.readFile "/run/agenix/wifi-gl3_env"))
    ];
    profiles = {
      "GL3-5G" = {
        connection = {
          id = "GL3-5G";
          type = "wifi";
          autoconnect = true;
        };
        wifi = {
          ssid = "sild-paa-daase";
          mode = "infrastructure";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$WIFI_PASS_5";
        };
      };
      "GL3" = {
        connection = {
          id = "GL3";
          type = "wifi";
          autoconnect = false;
        };
        wifi = {
          ssid = "sild-IoT";
          mode = "infrastructure";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$WIFI_PASS_24";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    nixos-install-tools
    rsync
    testdisk
    gparted
    bcachefs-tools
    btrfs-progs
    smartmontools
    nvme-cli
    ntfs3g
    pciutils
    usbutils
    htop
    btop
    wireguard-tools
    vscodium
    vim
    git
  ];
}
