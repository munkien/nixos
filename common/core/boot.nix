_: {
  boot = {
    loader.systemd-boot = {
      enable = true;
      memtest86.enable = true;
    };
    loader.efi.canTouchEfiVariables = true;
    initrd.systemd.enable = true;
    tmp.useTmpfs = true;
    kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
    };
  };
}
