{
  pkgs,
  lib,
  ...
}: {
  boot = {
    # Architecture-aware bootloader configuration
    loader = {
      # Disable systemd-boot for ARM/Generic, enable for x86_64
      systemd-boot.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;
      systemd-boot.memtest86.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;
      systemd-boot.configurationLimit = 30;

      efi.canTouchEfiVariables = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;
      generic-extlinux-compatible.enable = lib.mkDefault (!pkgs.stdenv.hostPlatform.isx86_64);
    };

    # Early-Boot & Persistence
    initrd = {
      systemd.enable = true;
      availableKernelModules = ["nvme" "xhci_pci" "usbhid"];
    };

    # Stateless Environment
    tmp = {
      useTmpfs = true;
      tmpfsSize = "50%";
    };

    # Fleet-wide Kernel Tuning
    kernel = {
      sysctl = {
        "fs.inotify.max_user_watches" = 524288;
        "vm.panic_on_oom" = 0;
        "kernel.sysrq" = 1;
      };
    };

    kernelParams = [
      "quiet"
      "udev.log_level=3"
    ];
  };
}
