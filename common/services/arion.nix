{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.arion
    pkgs.docker-client
  ];

  virtualisation.docker.enable = true;
  virtualisation.podman.enable = false;
  virtualisation.podman.dockerSocket.enable = true;

  users.extraUsers.munkien.extraGroups = ["podman" "docker"];

  virtualisation.arion.backend = "podman";
  virtualisation.arion.projects.home-infra.settings = {
    networks.internal_net = {};
  };
}
