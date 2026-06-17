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

  boot = {
    supportedFilesystems = ["bcachefs" "btrfs"];
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      availableKernelModules = ["nvme" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod"];
      supportedFilesystems = ["bcachefs" "btrfs"];
      kernelModules = ["amdgpu"];
      systemd.enable = true;
    };

    plymouth.enable = true;
    kernelModules = ["kvm-amd"];
    extraModulePackages = [];
    kernelParams = [
      "nvme.max_host_mem_size_mb=64"
      "pcie_aspm=off"
      "usbcore.autosuspend=-1"
      "snd_hda_intel.power_save=0"
      "snd_hda_intel.power_save_controller=N"
    ];

    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
    };

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    enableRedistributableFirmware = true;
    enableAllFirmware = true;

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };

  # For VA-API (Video Acceleration)
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  services = {
    xserver.videoDrivers = ["amdgpu"];

    pipewire.wireplumber.extraConfig."10-strict-audio-blacklist" = {
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

    blueman.enable = true;
  };

  # Swap Config
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };
}
