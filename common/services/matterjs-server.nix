{...}: {
  virtualisation.arion.projects.home-infra.settings.services.matterjs-server.service = {
    image = "ghcr.io/matter-js/matterjs-server:stable";
    container_name = "matterjs-server";

    volumes = [
      "/persist/var/lib/matterjs:/data"
    ];

    network_mode = "host";
    restart = "unless-stopped";
  };
}
