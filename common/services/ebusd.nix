{pkgs, ...}: {
  systemd.services.ebusd = {
    description = "ebusd daemon";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];

    serviceConfig = {
      # Ensure 'ebusd' is in your systemPackages so this path is valid
      ExecStart = "${pkgs.ebusd}/bin/ebusd \
      --device=ens:192.168.88.248:9999 \
      --mqtthost=127.0.0.1 \
      --mqttport=1883 \
      --mqttjson \
      --mqttclientid=ebusd-main-server \
      --accesslevel=* \
      --pollinterval=30 \
      --loglevel=notice \
      --listen=localhost:8888";
      Restart = "always";
      RestartSec = 10;
    };
  };

  # Ensure the package is actually installed
  environment.systemPackages = [pkgs.ebusd];

  # services.ebusd = {
  #   enable = true;
  #   device = "ens:192.168.88.248:9999";
  #   mqtt = {
  #     enable = true;
  #     host = "localhost";
  #     port = 1883;
  #     home-assistant = true;
  #   };
  #   extraOptions = [
  #     "--mqttjson"
  #     "--accesslevel=*"
  #     "--pollinterval=30"
  #   ];
  # };
}
