_: {
  boot.extraModprobeConfig = ''
    options iwlmvm power_scheme=1
  '';

  networking = {
    wireless.enable = false;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };
}
