{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.my.containers;
in {
  imports = [inputs.arion.nixosModules.arion];

  # `my.containers.user` is declared in modules/nixos/profile.nix so it exists on
  # every host, not just those importing arion.

  config = {
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

    # Grant container access to the host's user, if it declares one. Deliberately
    # not hardcoded to a username: a host without that account must still be able
    # to import this module.
    users.extraUsers = lib.optionalAttrs (cfg.user != null) {
      ${cfg.user}.extraGroups = ["podman" "docker"];
    };

    systemd.services."arion-home-infra" = {
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };

    preservation.preserveAt."/persist" = {
      directories = [
        "/var/lib/containers"
      ];
    };
  };
}
