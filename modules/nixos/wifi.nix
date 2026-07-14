_: {
  networking = {
    wireless.enable = false;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };
}
