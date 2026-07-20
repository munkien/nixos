_: {
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
}
