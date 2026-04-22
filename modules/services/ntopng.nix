{
  config,
  lib,
  ...
}: let
  common = import ./_base-quadlet.nix {inherit lib config;};
  cfg = config.my.services.ntopng;
in {
  options.my.services.ntopng = {
    enable = lib.mkEnableOption "ntopng network monitor";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.quadlet.containers.ntopng-redis = lib.recursiveUpdate common {
      containerConfig = {
        image = "docker.io/redis:7-alpine";
        exec = "redis-server --port 6399 --bind 127.0.0.1";
        networks = ["host"];
        healthCmd = "redis-cli -p 6399 ping || exit 1";
        healthInterval = "10s";
        healthRetries = 3;
        healthTimeout = "5s";
        healthStartPeriod = "5s";
        addCapabilities = ["SETUID" "SETGID"];
      };
    };

    virtualisation.quadlet.containers.ntopng = lib.recursiveUpdate common {
      unitConfig = {
        After = "ntopng-redis.service";
        Requires = "ntopng-redis.service";
        PartOf = "ntopng-redis.service";
      };
      containerConfig = {
        image = "docker.io/ntop/ntopng:latest";
        readOnly = false;
        networks = ["host"];
        exec = ''ntopng --community -r 127.0.0.1:6399 -l 1 --http-port 3000"'';
        userns = lib.mkForce "host";
        dropCapabilities = lib.mkForce [];
        addCapabilities = [
          "NET_RAW"
          "NET_ADMIN"
          "CHOWN"
          "SETUID"
          "SETGID"
          "DAC_OVERRIDE"
        ];
        healthCmd = "curl -sf http://localhost:3000 || exit 1";
        healthInterval = "30s";
        healthRetries = 5;
        healthTimeout = "10s";
        healthStartPeriod = "60s";
      };
    };

    networking.firewall.allowedTCPPorts = [3000];
    networking.firewall.allowedUDPPorts = [2055];
  };
}
