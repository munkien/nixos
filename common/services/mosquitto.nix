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
      "/var/lib/mosquitto"
    ];
  };

  networking.firewall.allowedTCPPorts = [1883];
}
