{
  config,
  lib,
  pkgs,
  ...
}: let
  common = import ./base-quadlet.nix {inherit lib config;};
in {
  # 1. Base directories
  systemd.tmpfiles.rules =
    map
    (d: "d /persist/services/omada${d} 0755 root root -")
    ["" "/db" "/data" "/logs"];

  # 2. Networking & Firewall
  networking.firewall = {
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

  # 4. Containers
  virtualisation.quadlet.containers = {
    omada-db = lib.recursiveUpdate common {
      containerConfig = {
        image = "docker.io/library/mongo:8";
        notify = "healthy";
        healthCmd = "mongosh --port 27017 --eval 'db.adminCommand(\"ping\").ok' --quiet || exit 1";
        publishPorts = ["127.0.0.1:27017:27017"];
        tmpfses = ["/tmp" "/data/configdb"];
        exec = "mongod --bind_ip_all --wiredTigerCacheSizeGB 0.5 --quiet";
        volumes = ["/persist/services/omada/db:/data/db:rw,Z,U"];
      };
    };

    omada = lib.recursiveUpdate common {
      unitConfig = {
        Requires = "omada-db.service";
        After = "omada-db.service";
      };
      containerConfig = {
        image = "docker.io/mbentley/omada-controller:6";
        ulimits = ["nofile=4096:8192"];
        networks = ["host"];
        readOnly = false;
        notify = "healthy";
        healthStartPeriod = "5m";
        healthCmd = "wget --quiet --tries=1 --no-check-certificate --spider http://127.0.0.1:8088/ || exit 1";
        environments = {
          ROOTLESS = "true";
          MONGO_EXTERNAL = "true";
          EAP_MONGOD_URI = "mongodb://127.0.0.1:27017/omada";
        };
        volumes = [
          "/persist/services/omada/data:/opt/tplink/EAPController/data:rw,Z,U"
          "/persist/services/omada/logs:/opt/tplink/EAPController/logs:rw,Z,U"
        ];
      };
    };
  };
}
