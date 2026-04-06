{
  pkgs,
  inputs,
  ...
}: {
  boot = {
    loader.systemd-boot = {
      enable = true;
      memtest86.enable = true;
    };
    loader.efi.canTouchEfiVariables = true;
    initrd.systemd.enable = true;
    tmp.useTmpfs = true;
  };
}
