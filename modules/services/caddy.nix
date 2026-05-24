{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.services.caddy.configFile = mkOption {
    type = types.nullOr types.path;
    default = null;
    description = "Path to Caddyfile (setting this auto-enables Caddy)";
  };

  config = mkIf (config.services.caddy.configFile != null) {
    services.caddy = {
      enable = true;
      configFile = config.services.caddy.configFile;
    };

    systemd.services.caddy = {
      serviceConfig = {
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectHostname = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;
        LockPersonality = true;

        # Syscall filtering
        SystemCallFilter = ["@system-service" "~@privileged" "~@resources"];
        SystemCallErrorNumber = "EPERM";

        # Capabilities
        CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE" "CAP_NET_RAW"];
        AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];

        # Network restrictions
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];

        # Read-only paths
        ReadWritePaths = [
          "/var/lib/caddy"
          "/var/cache/caddy"
          "/run/caddy"
        ];
      };
    };
  };
}
