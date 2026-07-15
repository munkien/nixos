{...}: {
  services.mosquitto = {
    enable = true;
    persistence = true;
  };

  preservation.preserveAt."/persist" = {
    directories = [
      "/var/lib/mosquitto"
    ];
  };
}
