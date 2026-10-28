{
  lib,
  config,
  ...
}: let
  cfg = config.my.services;

  # One declaration per service: which ports it needs open, and (optionally)
  # which public hostname should reverse-proxy to it.
  serviceType = lib.types.submodule {
    options = {
      ports = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = ''
          Ports to open in the firewall. For a service using
          network_mode = "host", these are the ports the process itself binds.
          For a bridged container, list the host side of each published port.
        '';
      };

      udpPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [];
        description = "Ports to open in the firewall for UDP.";
      };

      hostname = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "ha.munkie.dk";
        description = ''
          Public hostname. When set, a Caddy virtual host is generated that
          reverse-proxies to 127.0.0.1:<proxyPort>. Requires caddy to be
          imported by the host.
        '';
      };

      proxyPort = lib.mkOption {
        type = lib.types.nullOr lib.types.port;
        default = null;
        description = ''
          Port the reverse proxy should target, when it differs from the
          service's own port. Used by bridged containers, whose built-in port
          is published to a different host port.
        '';
      };
    };
  };
in {
  options.my.services = lib.mkOption {
    type = lib.types.attrsOf serviceType;
    default = {};
    description = ''
      Services to expose on this host, keyed by service name. Declaring an entry
      is what makes a service reachable: a name here with no matching module
      still opens its ports, which is deliberate — the point is that exposure
      lives in one place instead of being scattered across service modules.
    '';
    example = {
      mosquitto.ports = [1883];
      homeassistant = {
        ports = [8123];
        hostname = "ha.munkie.dk";
        proxyPort = 8123;
      };
    };
  };

  config = {
    networking.firewall.allowedTCPPorts =
      lib.concatMap (s: s.ports) (lib.attrValues cfg);

    networking.firewall.allowedUDPPorts =
      lib.concatMap (s: s.udpPorts) (lib.attrValues cfg);

    services.caddy.virtualHosts = lib.mkMerge (
      lib.mapAttrsToList (
        _name: s:
          lib.optionalAttrs (s.hostname != null) {
            ${s.hostname} = {
              extraConfig = ''
                reverse_proxy 127.0.0.1:${toString (
                  if s.proxyPort != null
                  then s.proxyPort
                  else builtins.head s.ports
                )}
              '';
            };
          }
      )
      cfg
    );
  };
}
