{
  lib,
  config,
  ...
}: {
  options.my.services.mosquitto.enable = lib.mkEnableOption "Mosquitto MQTT Broker";
  config = lib.mkIf config.my.services.mosquitto.enable {
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          port = 1883;
          # Strictly bind to localhost to isolate the broker from the LAN
          address = "127.0.0.1";

          acl = ["pattern readwrite #"];
          omitPasswordAuth = true;
          settings = {
            allow_anonymous = true;
          };
        }
      ];
    };
  };
}
