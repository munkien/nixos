_: {
  virtualisation.arion.projects.home-infra.settings.services.homeassistant.service = {
    image = "ghcr.io/home-assistant/home-assistant:2026.8.1";
    container_name = "homeassistant";

    environment = {
      TZ = "Europe/Copenhagen";
    };

    volumes = [
      "/persist/var/lib/homeassistant:/config"
      "/etc/localtime:/etc/localtime:ro"
      "/run/dbus:/run/dbus:ro"
    ];

    network_mode = "host";
    privileged = true;
    restart = "always";
  };

  # Exposure (vhost + firewall) is declared by the host via my.services.
}
