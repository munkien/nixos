{
  homeassistant = {
    name = "Home Assistant";
    latitude = 55.7;
    longitude = 12.6;
    elevation = 10;
    unit_system = "metric";
    external_url = "https://homeassistant.lan.munkie.dk";
    internal_url = "http://homeassistant.lan.munkie.dk:8123";
  };

  http = {
    server_port = 8123;
    use_x_forwarded_for = true;
  };

  logger = {
    default = "info";
  };
}
