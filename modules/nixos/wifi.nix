{pkgs, ...}: {
  networking = {
    wireless.enable = false;
    wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      dhcp = "internal";
      wifi = {
        backend = "iwd";
        powersave = false;
      };
    };
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="${pkgs.iw}/bin/iw dev %k set power_save off"
  '';
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
  '';

  networking.wireless.iwd.settings = {
    Roam = {
      RoamRetryInterval = 15;
    };
  };
}
