{
  config,
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = [pkgs.restic];

  sops.secrets = {
    "restic-password" = {
      owner = "root";
      sopsFile = ./secrets/backup.yaml;
    };
    "restic-s3-env" = {
      owner = "root";
      sopsFile = ./secrets/backup.yaml;
    };
  };

  systemd.services."restic-backups-container-data" = {
    serviceConfig = {
      TimeoutStartSec = "10min";
      TimeoutStopSec = "10min";
    };
  };
  services.restic.backups.container-data = {
    initialize = true;
    repository = "s3:https://hel1.your-objectstorage.com/munkien-homelab";
    environmentFile = config.sops.secrets."restic-s3-env".path;
    passwordFile = config.sops.secrets."restic-password".path;
    paths = ["/persist"];
    extraBackupArgs = [
      "--compression max"
    ];
    backupPrepareCommand = ''
      SERVICES=$(${pkgs.findutils}/bin/find /etc/containers/systemd -name "*.container" -exec basename {} .container \; | ${pkgs.gnused}/bin/sed 's/$/.service/')

      for service in $SERVICES; do
        echo "Stopping service: $service"
        ${pkgs.systemd}/bin/systemctl stop "$service" || true
      done
    '';

    backupCleanupCommand = ''
      SERVICES=$(${pkgs.findutils}/bin/find /etc/containers/systemd -name "*.container" -exec basename {} .container \; | ${pkgs.gnused}/bin/sed 's/$/.service/')

      for service in $SERVICES; do
        echo "Starting service: $service"
        ${pkgs.systemd}/bin/systemctl start "$service" --no-block || true
      done
    '';
    timerConfig = {
      OnCalendar = "02:00";
      RandomizedDelaySec = "2h";
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };
}
