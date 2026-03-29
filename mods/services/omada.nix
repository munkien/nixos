{
  config,
  lib,
  pkgs,
  ...
}: let
  common = import ./base-quadlet.nix {inherit lib config;};
  persistBase = "/persist/services/omada";
  snapshotDir = "/persist/snapshots/omada";
in {
  systemd.tmpfiles.rules = [
    "d ${persistBase}      0750 root root -"
    "d ${persistBase}/data 0755 508  508  -"
    "d ${persistBase}/logs 0755 508  508  -"
    "d ${snapshotDir}      0750 root root -"
  ];

  users.groups.omada = {gid = 508;};
  users.users.omada = {
    uid = 508;
    group = "omada";
    isSystemUser = true;
  };

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
      User = "root";
    };
    path = with pkgs; [coreutils findutils podman];
    script = ''
      set -euo pipefail

      check_space() {
        AVAILABLE=$(df --output=avail "$1" | tail -1)
        REQUIRED=$(du -sk "$2" | cut -f1)
        if [ "$AVAILABLE" -lt "$((REQUIRED * 2))" ]; then
          echo "ERROR: insufficient disk space for snapshot, skipping"
          return 1
        fi
      }

      repair() {
        podman run --rm \
          --pull never \
          --user 508:508 \
          --volume "$1:/data/db:z" \
          docker.io/library/mongo:8 \
          mongod --repair --dbpath /data/db --quiet
      }

      restore() {
        GOOD=$(find ${snapshotDir} -maxdepth 1 -mindepth 1 -type d | sort | tail -1)
        if [ -z "$GOOD" ]; then
          echo "ERROR: no good snapshot available, proceeding with corrupt data"
          return 1
        fi
        echo "Restoring from $GOOD"
        rm -rf ${persistBase}/data
        cp -a --reflink=auto "$GOOD" ${persistBase}/data
        chown -R 508:508 ${persistBase}/data
      }

      # --- Verify latest snapshot WiredTiger ---
      LATEST=$(find ${snapshotDir} -maxdepth 1 -mindepth 1 -type d | sort | tail -1)
      if [ -n "$LATEST" ]; then
        echo "Verifying snapshot: $LATEST"
        if ! repair "$LATEST/db"; then
          echo "WARNING: snapshot WiredTiger unrecoverable, discarding"
          rm -rf "$LATEST"
        else
          echo "Snapshot OK"
        fi
      fi

      # --- Verify live WiredTiger ---
      echo "Verifying live data..."
      if [ -d "${persistBase}/data/db" ]; then
        if ! repair "${persistBase}/data/db"; then
          echo "Live WiredTiger corrupt and unrecoverable — restoring from snapshot"
          restore
        else
          echo "Live data OK"
        fi
      else
        echo "No live db dir found — restoring from snapshot if available"
        restore || true
      fi

      # --- Pre-start snapshot ---
      if check_space "${snapshotDir}" "${persistBase}/data"; then
        STAMP=$(date +%Y%m%d-%H%M%S)
        echo "Pre-start snapshot: ${snapshotDir}/$STAMP"
        cp -a --reflink=auto ${persistBase}/data "${snapshotDir}/$STAMP"
      fi

      # Keep 7 most recent snapshots by sort order, not mtime
      find ${snapshotDir} -maxdepth 1 -mindepth 1 -type d | sort | head -n -7 | xargs -r rm -rf
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
      userns = "host";
      ulimits = ["nofile=4096:8192"];
      networks = ["host"];
      notify = "healthy";
      healthStartPeriod = "5m";
      healthCmd = "wget --quiet --tries=1 --no-check-certificate --spider http://127.0.0.1:8088/ || exit 1";
      stopTimeout = 60;
      environments = {
        TZ = "Europe/Copenhagen";
        PUID = "508";
        PGID = "508";
        SHOW_SERVER_LOGS = "true";
      };
      volumes = [
        "${persistBase}/data:/opt/tplink/EAPController/data:rw,Z"
        "${persistBase}/logs:/opt/tplink/EAPController/logs:rw,Z"
      ];
    };
  };

  systemd.services.omada-snapshot = {
    description = "Nightly clean Omada snapshot";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      User = "root";
    };
    path = with pkgs; [coreutils findutils systemd];
    script = ''
      set -euo pipefail
      STAMP=$(date +%Y%m%d-%H%M%S)

      AVAILABLE=$(df --output=avail ${snapshotDir} | tail -1)
      REQUIRED=$(du -sk ${persistBase}/data | cut -f1)
      if [ "$AVAILABLE" -lt "$((REQUIRED * 2))" ]; then
        echo "ERROR: insufficient disk space for snapshot, aborting"
        systemd-cat -t omada-snapshot echo "CRITICAL: omada nightly snapshot skipped — insufficient disk space"
        exit 1
      fi

      systemctl stop omada.service
      cp -a --reflink=auto ${persistBase}/data "${snapshotDir}/$STAMP"
      systemctl start omada.service || {
        systemd-cat -t omada-snapshot echo "CRITICAL: omada did not restart after nightly snapshot"
        exit 1
      }

      # Keep 7 most recent snapshots by sort order, not mtime
      find ${snapshotDir} -maxdepth 1 -mindepth 1 -type d | sort | head -n -7 | xargs -r rm -rf
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
