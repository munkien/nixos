{...}: {
  services.ebusd = {
    enable = true;
    device = "ens:192.168.88.248:9999";
    mqtt = {
      enable = true;
      host = "localhost";
      port = 1883;
      home-assistant = true;
      user = "ebusd";
      password = "";
      retain = true;
    };
    extraArguments = [
      "--mqttjson"
      "--mqttretain"
      "--accesslevel=*"
      "--pollinterval=30"
    ];
  };
}
