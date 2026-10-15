{
  pkgs,
  lib,
  ...
}: {
  boot = {
    # Architecture-aware bootloader configuration
    loader = {
      # Disable systemd-boot for ARM/Generic, enable for x86_64
      systemd-boot = {
        enable = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;
        memtest86.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;
        configurationLimit = 30;
      };

      efi.canTouchEfiVariables = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;
      generic-extlinux-compatible.enable = lib.mkDefault (!pkgs.stdenv.hostPlatform.isx86_64);
    };

    # Automatic Boot Assessment: a new generation is given `tries` boot attempts.
    # Each boot decrements a counter; reaching boot-complete.target makes
    # systemd-bless-boot.service mark the entry good. A generation whose counter
    # reaches zero is skipped in favour of the previous one. This is the local,
    # network-independent rollback path: it works even when the broken generation
    # is itself what breaks networking.
    #
    # Requires systemd-boot, which is x86_64-only here (see above); other
    # platforms keep generic-extlinux-compatible and have no automatic fallback.
    #
    # Note: boot-complete.target is gated further by the fleet-health-check unit
    # in ./boot-health.nix, so "good" means the health checks passed, not merely
    # that userspace came up.
    loader.systemd-boot.bootCounting = {
      enable = lib.mkDefault pkgs.stdenv.hostPlatform.isx86_64;
      tries = 3;
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
