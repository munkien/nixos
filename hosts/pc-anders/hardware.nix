{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.systemPackages = with pkgs; [
    bcachefs-tools
    ntfs3g
    gparted
  ];

  boot.supportedFilesystems = ["bcachefs" "btrfs"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.supportedFilesystems = ["bcachefs" "btrfs"];
  boot.initrd.kernelModules = ["amdgpu"];
  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];
  boot.kernelParams = [
    "nvme.max_host_mem_size_mb=64"
    "pcie_aspm=off"
    "usbcore.autosuspend=-1"
    "snd_hda_intel.power_save=0"
    "snd_hda_intel.power_save_controller=N"
  ];

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  services.xserver.videoDrivers = ["amdgpu"];

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  services.pipewire.wireplumber.extraConfig."10-strict-audio-blacklist" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          # Disables GPU HDMI/DP audio (Navi) and Motherboard audio (Starship)
          {"node.name" = "~alsa_output.pci.*";}
          # Disables the AB13X and generic CS202 USB adapters
          {"node.name" = "~alsa_output.usb-Generic.*";}
          {"node.name" = "~alsa_output.usb-AB13X.*";}
        ];
        actions = {
          update-props = {
            "node.disabled" = true;
          };
        };
      }
    ];
  };

  # Swap Config
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;
}
