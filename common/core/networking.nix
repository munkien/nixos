_: {
  networking = {
    wireless.enable = false;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
