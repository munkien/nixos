{...}: {
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://127.0.0.1:1883";
      };
      serial = {
        port = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
      };
      frontend = {
        port = 8321;
      };
      # Enable availability for HA
      advanced.availability_timeout = 60;
    };
  };

  networking.firewall.allowedTCPPorts = [8321];

  preservation.preserveAt."/persist" = {
    directories = [
      "/var/lib/zigbee2mqtt"
    ];
  };
}
