{
  config,
  pkgs,
  ...
}: {
  services.gatus = {
    enable = true;

    # This translates directly into the Gatus config.yaml
    settings = {
      endpoints = [
        # 1. HTTP Monitor (e.g., Frigate)
        {
          name = "Frigate Web UI";
          group = "Smart Home";
          url = "http://localhost:5000"; # Replace with actual container IP or hostname
          interval = "1m";
          conditions = [
            "[STATUS] == 200"
            "[RESPONSE_TIME] < 500"
          ];
        }

        # 2. TCP/MQTT Monitor (e.g., Mosquitto)
        {
          name = "Mosquitto MQTT";
          group = "Smart Home";
          url = "tcp://localhost:1883";
          interval = "1m";
          conditions = [
            "[CONNECTED] == true"
          ];
        }
      ];

      # Optional: Serve the Gatus UI on a specific port
      web.port = 8080;
    };
  };

  # Open the firewall for the Gatus dashboard
  networking.firewall.allowedTCPPorts = [8080];
}
