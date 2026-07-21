{pkgs, ...}: {
  networking = {
    wireless.enable = false;
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
    options iwlmvm power_scheme=1
  '';

  networking.wireless.iwd.settings = {
    Roam = {
      RoamRetryInterval = 15;
      RoamThreshold = -75;
    };
  };
}
