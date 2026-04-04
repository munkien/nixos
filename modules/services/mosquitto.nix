{
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

  # The firewall rule has been deliberately removed.
  # Localhost traffic (127.0.0.1) is intrinsically allowed and does not need firewall holes.
}
