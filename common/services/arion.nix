{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.arion
    pkgs.docker-client
  ];

  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;

  users.extraUsers.munkien.extraGroups = ["podman" "docker"];

  virtualisation.arion.backend = "podman";
  virtualisation.arion.projects.home-infra.settings = {
    networks.internal_net = {};
  };
}
