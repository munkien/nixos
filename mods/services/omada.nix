{
  config,
  lib,
  pkgs,
  ...
}: let
  common = import ./base-quadlet.nix {inherit lib config;};
  persistBase = "/persist/services/omada";
in {
  systemd.tmpfiles.rules = map (args: "d ${persistBase}${args}") [
    "/db   0750 mongodb     mongodb    -"
    "/data 0755 containers  containers -"
    "/logs 0755 containers  containers -"
  ];

  networking.firewall = {
    allowedTCPPorts = [80 443 8088 8043];
    allowedTCPPortRanges = [
      {
        from = 29811;
        to = 29817;
      }
    ];
    allowedUDPPorts = [19810 27001 29810];
  };

  # 3. Reverse proxy
  services.caddy.virtualHosts."omada.lan.munkie.dk" = {
    useACMEHost = "munkie.dk";
    extraConfig = ''
      import secure_proxy
      reverse_proxy 127.0.0.1:8088
    '';
  };

  services.mongodb = {
    enable = true;
    package = pkgs.mongodb-6_0;
    bind_ip = "127.0.0.1";
    dbpath = "${persistBase}/db";
    extraConfig = ''
      storage:
        wiredTiger:
          engineConfig:
            cacheSizeGB: 0.5
      systemLog:
        quiet: true
    '';
  };

  virtualisation.quadlet.containers.omada = lib.recursiveUpdate common {
    unitConfig = {
      Requires = "mongodb.service";
      After = "mongodb.service";
    };
    containerConfig = {
      image = "docker.io/mbentley/omada-controller:6";
      user = "508:508";
      ulimits = ["nofile=4096:8192"];
      networks = ["host"];
      notify = "healthy";
      healthStartPeriod = "5m";
      healthCmd = "wget --quiet --tries=1 --no-check-certificate --spider http://127.0.0.1:8088/ || exit 1";
      environments = {
        ROOTLESS = "true";
        MONGO_EXTERNAL = "true";
        EAP_MONGOD_URI = "mongodb://127.0.0.1:27017/omada";
      };
      volumes = [
        "${persistBase}/data:/opt/tplink/EAPController/data:rw,Z,U"
        "${persistBase}/logs:/opt/tplink/EAPController/logs:rw,Z,U"
      ];
    };
  };
}
