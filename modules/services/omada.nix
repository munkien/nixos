{
  config,
  lib,
  pkgs,
  ...
}: let
  common = import ./base-quadlet.nix {inherit lib config;};
  persistBase = "/persist/services/omada";
in {
  systemd.tmpfiles.rules = [
    "d ${persistBase}      0750 root root -"
    "d ${persistBase}/data 0755 omada omada -"
    "d ${persistBase}/logs 0755 omada omada -"
  ];

  users.groups.omada = {gid = 508;};
  users.users.omada = {
    uid = 508;
    group = "omada";
    isSystemUser = true;
  };

  networking.firewall = {
    allowedTCPPorts = [8088 8043];
    allowedTCPPortRanges = [
      {
        from = 29811;
        to = 29817;
      }
    ];
    allowedUDPPorts = [19810 27001 27002 29810];
  };

  services.caddy.virtualHosts."omada.lan.munkie.dk" = {
    useACMEHost = "munkie.dk";
    extraConfig = ''
      import secure_proxy
      reverse_proxy 127.0.0.1:8088
    '';
  };

  virtualisation.quadlet.containers.omada = lib.recursiveUpdate common {
    containerConfig = {
      image = "docker.io/mbentley/omada-controller:6";
      userns = "host";
      networks = ["host"];
      readOnly = false;
      dropCapabilities = [];
      ulimits = ["nofile=4096:8192"];
      notify = "healthy";
      healthStartPeriod = "5m";
      healthCmd = "wget --quiet --tries=1 --no-check-certificate --spider http://127.0.0.1:8088/ || exit 1";
      stopTimeout = 60;
      environments = {
        TZ = "Europe/Copenhagen";
        PUID = "508";
        PGID = "508";
      };
      volumes = [
        "${persistBase}/data:/opt/tplink/EAPController/data:rw,Z"
        "${persistBase}/logs:/opt/tplink/EAPController/logs:rw,Z"
      ];
    };
  };
}
