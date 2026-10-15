{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.arion.nixosModules.arion];

  environment.systemPackages = [
    pkgs.arion
    pkgs.docker-client
  ];

  virtualisation = {
    docker.enable = false;
    podman = {
      enable = true;
      dockerSocket.enable = true;
    };

    arion.backend = "podman-socket";
    arion.projects.home-infra.settings = {
      networks.internal_net = {};
    };
  };

  systemd.timers."podman-auto-update" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  users.extraUsers.munkien.extraGroups = ["podman" "docker"];

  systemd.services."arion-home-infra" = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };

  preservation.preserveAt."/persist" = {
    directories = [
      "/var/lib/containers"
    ];
  };
}
