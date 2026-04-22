{
  config,
  lib,
  ...
}: let
  common = import ./_base-quadlet.nix {inherit lib config;};
  cfg = config.my.services.ialarm;
in {
  options.my.services.ialarm = {
    enable = lib.mkEnableOption "iAlarm MQTT bridge";
  };

  config = lib.mkIf cfg.enable {
    age.secrets."ialarm-config" = {
      rekeyFile = ../../secrets/services/ialarm/ialarm.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    virtualisation.quadlet.containers.ialarm-mqtt = lib.recursiveUpdate common {
      containerConfig = {
        user = "root";
        image = "docker.io/maxill1/ialarm-mqtt:v0.12.0";

        networks = ["host"];

        volumes = [
          "${config.age.secrets."ialarm-config".path}:/config/config.yaml:ro"
        ];

        # --- Healthcheck Configuration ---
        healthCmd = "ps -A | grep node || exit 1";
        healthInterval = "30s";
        healthRetries = 3;
        healthTimeout = "10s";
        healthStartPeriod = "15s";
      };
    };
  };
}
