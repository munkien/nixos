{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.arion
    pkgs.docker-client
  ];

  virtualisation.docker.enable = true;
  virtualisation.podman.enable = false;
  virtualisation.podman.dockerSocket.enable = true;

  users.extraUsers.munkien.extraGroups = ["podman" "docker"];

  virtualisation.arion.backend = "docker";
  virtualisation.arion.projects.home-infra.settings = {
    networks.internal_net = {};

    services.watchtower.service = {
      image = "containrrr/watchtower:latest";
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
      ];
      environment = {
        WATCHTOWER_CLEANUP = "true";
        WATCHTOWER_POLL_INTERVAL = "86400";
      };
      restart = "always";
    };
  };
}
