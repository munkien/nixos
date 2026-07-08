{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.arion
    pkgs.docker-client
  ];

  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;

  users.extraUsers.munkien.extraGroups = ["podman" "docker"];

  systemd.services."arion-home-infra" = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };

  virtualisation.arion.backend = "podman-socket";
  virtualisation.arion.projects.home-infra.settings = {
    networks.internal_net = {};
  };
}
