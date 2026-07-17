{...}: {
  services.mosquitto = {
    enable = true;
    persistence = true;
  };

  preservation.preserveAt."/persist" = {
    directories = [
      "/var/lib/mosquitto"
    ];
  };

  networking.firewall.allowedTCPPorts = [1883];
  networking.firewall.allowedUDPPorts = [1883];
}
