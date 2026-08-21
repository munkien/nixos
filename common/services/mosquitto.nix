{...}: {
  services.mosquitto = {
    enable = true;
    persistence = true;
    listeners = [
      {
        acl = ["pattern readwrite #"];
        omitPasswordAuth = true; # Warning: Only use this for internal trusted network testing
        settings = {
          allow_anonymous = true;
        };
      }
    ];
  };

  preservation.preserveAt."/persist" = {
    directories = [
      {
        directory = "/var/lib/mosquitto";
        user = "mosquitto";
        group = "mosquitto";
        mode = "0750";
      }
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/mosquitto 0750 mosquitto mosquitto - -"
  ];

  networking.firewall.allowedTCPPorts = [1883];
}
