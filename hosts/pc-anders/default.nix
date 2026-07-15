{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../users/munkien

    ./filesystem.nix
    ./wifi.nix
  ];

  system.stateVersion = "26.11";

  my = {
    desktop.enable = true;
    gaming.enable = true;
  };

  services.comin.enable = true;

  hardware = {
    facter = {
      enable = true;
      reportPath = ./facter.json;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
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
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "pc-anders";
  age.rekey.hostPubkey = lib.strings.trim (builtins.readFile ./hostPubkey.pub);

  systemd.services.systemd-machine-id-commit.enable = false;
  environment.etc."machine-id".text = "5f8c8eac5b85429fb8dc3d633e5b42e6";

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

  boot = {
    supportedFilesystems = ["bcachefs" "btrfs"];
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      availableKernelModules = ["nvme" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod"];
      supportedFilesystems = ["bcachefs" "btrfs"];
      kernelModules = ["amdgpu"];
      systemd.enable = true;
    };

    plymouth = {
      enable = true;
      themePackages = [pkgs.plymouth-matrix-theme];
    };

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
}
