{...}: {
  services.ebusd = {
    enable = true;
    device = "ens:192.168.88.248:9999";
    mqtt = {
      enable = true;
      host = "localhost";
      port = 1883;
      home-assistant = true;
    };
    extraOptions = [
      "--mqttjson"
      "--accesslevel=*"
      "--pollinterval=30"
    ];
  };

  networking.firewall.allowedTCPPorts = [8888 8080];
}
