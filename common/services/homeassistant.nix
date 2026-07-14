{pkgs, ...}: {
  system.activationScripts.homeassistantDirs = ''
    mkdir -p /var/lib/homeassistant
  '';

  virtualisation.arion.projects.home-infra.settings.services.homeassistant.service = {
    image = "ghcr.io/home-assistant/home-assistant:stable";
    container_name = "homeassistant";

    environment = {
      TZ = "Europe/Copenhagen";
    };

    volumes = [
      "/var/lib/homeassistant:/config"
      "/etc/localtime:/etc/localtime:ro"
      "/run/dbus:/run/dbus:ro"
    ];

    network_mode = "host";
    privileged = true;
    restart = "always";
  };

  services.caddy.virtualHosts."ha.munkie.dk" = {
    extraConfig = ''
      reverse_proxy 127.0.0.1:8123
    '';
  };

  # Open the port if you ever need to bypass Caddy locally
  networking.firewall.allowedTCPPorts = [8123];

  preservation.preserveAt."/persist" = {
    directories = [
      "/var/lib/homeassistant"
    ];
  };
}
