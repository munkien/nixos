{
  config,
  lib,
  pkgs,
  ...
}: let
  common = import ./base-quadlet.nix {inherit lib config;};
  persistBase = "/persist/services/omada";
  snapshotDir = "/persist/omada/snapshots";

  repairCmd = path: ''
    ${pkgs.podman}/bin/podman run --rm \
      --volume "${path}:/data/db:Z" \
      docker.io/library/mongo:8 \
      mongod --repair --dbpath /data/db --quiet
  '';
in {
  systemd.tmpfiles.rules = [
    "d ${persistBase}      0750 root root -"
    "d ${persistBase}/data 0750 root root -"
    "d ${persistBase}/logs 0750 root root -"
    "d ${snapshotDir}      0750 root root -"
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

  services.caddy.virtualHosts."omada.lan.munkie.dk" = {
    useACMEHost = "munkie.dk";
    extraConfig = ''
      import secure_proxy
      reverse_proxy 127.0.0.1:8088
    '';
  };

  systemd.services.omada-prestart = {
    description = "Verify and snapshot Omada data before start";
    before = ["omada.service"];
    wantedBy = ["omada.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
    path = with pkgs; [coreutils findutils podman];
    script = ''
      set -euo pipefail

      LATEST=$(find ${snapshotDir} -maxdepth 1 -mindepth 1 -type d | sort | tail -1)
      if [ -n "$LATEST" ]; then
        echo "Verifying snapshot: $LATEST"
        if ! ${repairCmd "$LATEST"}; then
          echo "WARNING: snapshot unrecoverable, discarding $LATEST"
          rm -rf "$LATEST"
        else
          echo "Snapshot OK"
        fi
      fi

      echo "Verifying live data..."
      if ! ${repairCmd "${persistBase}/data"}; then
        GOOD=$(find ${snapshotDir} -maxdepth 1 -mindepth 1 -type d | sort | tail -1)
        if [ -z "$GOOD" ]; then
          echo "ERROR: no good snapshot available, proceeding with corrupt data"
        else
          echo "Restoring from $GOOD"
          rm -rf ${persistBase}/data
          cp -a --reflink=auto "$GOOD" ${persistBase}/data
        fi
      else
        echo "Live data OK"
      fi

      STAMP=$(date +%Y%m%d-%H%M%S)
      echo "Snapshotting to ${snapshotDir}/$STAMP"
      cp -a --reflink=auto ${persistBase}/data "${snapshotDir}/$STAMP"

      find ${snapshotDir} -maxdepth 1 -mindepth 1 -type d -mtime +7 -exec rm -rf {} +
      echo "Pre-start complete"
    '';
  };

  virtualisation.quadlet.containers.omada = lib.recursiveUpdate common {
    unitConfig = {
      Requires = "omada-prestart.service";
      After = "omada-prestart.service";
    };
    containerConfig = {
      image = "docker.io/mbentley/omada-controller:6";
      user = "508:508";
      ulimits = ["nofile=4096:8192"];
      networks = ["host"];
      notify = "healthy";
      healthStartPeriod = "5m";
      healthCmd = "wget --quiet --tries=1 --no-check-certificate --spider http://127.0.0.1:8088/ || exit 1";
      stopTimeout = 60;
      userNs = "auto";
      environments = {
        TZ = "Europe/Copenhagen";
        PUID = "508";
        PGID = "508";
        SHOW_SERVER_LOGS = "true";
      };
      volumes = [
        "${persistBase}/data:/opt/tplink/EAPController/data:rw,Z,U"
        "${persistBase}/logs:/opt/tplink/EAPController/logs:rw,Z,U"
      ];
    };
  };

  systemd.services.omada-snapshot = {
    description = "Nightly clean Omada snapshot";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
    path = with pkgs; [coreutils findutils systemd];
    script = ''
      set -euo pipefail
      STAMP=$(date +%Y%m%d-%H%M%S)

      systemctl stop omada.service
      cp -a --reflink=auto ${persistBase}/data "${snapshotDir}/$STAMP"
      systemctl start omada.service

      find ${snapshotDir} -maxdepth 1 -mindepth 1 -type d -mtime +7 -exec rm -rf {} +
    '';
  };

  systemd.timers.omada-snapshot = {
    description = "Nightly Omada snapshot timer";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
      RandomizedDelaySec = "10m";
    };
  };
}
