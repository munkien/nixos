{
  config,
  lib,
  ...
}: let
  domain = "munkie.dk";
  appUrl = "z2m.lan.${domain}";
  authUrl = "id.lan.${domain}";
  port = 1880;
  persistDir =
    if config.my.impermanence.enable
    then "${config.my.impermanence.persistPath}/services/zigbee2mqtt"
    else "/var/lib/zigbee2mqtt";
in {
  options.my.services.zigbee2mqtt.enable = lib.mkEnableOption "Zigbee2MQTT";
  config = lib.mkIf config.my.services.zigbee2mqtt.enable {
    # Declaratively ensure the persistent directory exists
    systemd.tmpfiles.rules = [
      "d ${persistDir} 0750 zigbee2mqtt zigbee2mqtt -"
    ];

    services.caddy.virtualHosts."${appUrl}" = {
      useACMEHost = domain;
      extraConfig = ''
        forward_auth 127.0.0.1:9091 {
            uri /api/verify?rd=https://${authUrl}/
            copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
        }
        reverse_proxy 127.0.0.1:${toString port}
      '';
    };

    services.zigbee2mqtt = {
      enable = true;
      dataDir = persistDir;

      settings = {
        # Hardcoded to true since HA is running via Podman
        homeassistant = lib.mkForce true;

        # SECURITY: Deny automatic pairing
        permit_join = false;

        frontend = {
          # SECURITY: Bind strictly to localhost to enforce Authelia proxy
          host = "127.0.0.1";
          inherit port;
        };

        mqtt = {
          server = "mqtt://127.0.0.1:1883";
        };

        serial = {
          # Reverted to ezsp for older coordinator hardware support
          adapter = "ezsp";
          port = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
        };

        advanced = {
          # SECURITY: Generate a random encryption key on first startup
          network_key = "GENERATE";
        };
      };
    };
  };
}
