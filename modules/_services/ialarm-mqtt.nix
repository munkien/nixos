{
  config,
  lib,
  ...
}: let
  common = import ./common-quadlet.nix {inherit lib;};
in {
  # 1. Declare your secrets (requires keys to be added to your sops file)
  sops.secrets."ialarm_username" = {sopsFile = ../secrets/ialarm.yaml;};
  sops.secrets."ialarm_password" = {sopsFile = ../secrets/ialarm.yaml;};

  # 2. Declaratively generate the YAML file at runtime using SOPS templates.
  # This safely injects the secrets without leaking them into the /nix/store.
  sops.templates."ialarm-config.yaml".content = ''
    verbose: false
    server:
      host: "47.91.74.102"
      port: 18034
      username: "${config.sops.placeholder."ialarm_username"}"
      password: "${config.sops.placeholder."ialarm_password"}"

      # Dynamically generate the [1, 2, ..., 17] array
      zones: ${builtins.toJSON (lib.range 1 17)}

      showUnnamedZones: false
      areas: "1"
      delay: 500
      features:
        - armDisarm
        - sensors
        - events
        - bypass
        - zoneNames
      polling_status: 10000
    mqtt:
      host: "127.0.0.1"
      port: 1883
      username: "ialarm-mqtt"
      password: ""
      clientId: "ialarm-mqtt"
      cache: "1m"
      retain: true
    hadiscovery:
      alarm_qos: "2"
      sensors_qos: "0"
      zoneName: "Zone"
    events:
      name: "last event"
      icon: "mdi:message-alert"
    bypass:
      name: "Bypass"
      icon: "mdi:lock-open"
    zones: []
    name: "Alarm"
  '';

  virtualisation.quadlet.containers.ialarm-mqtt = lib.recursiveUpdate common {
    containerConfig = {
      user = "root";
      # Pinned to your specific version
      image = "docker.io/maxill1/ialarm-mqtt:v0.12.0";

      networks = ["host"];

      volumes = [
        # Mount the securely rendered SOPS template directly as read-only
        "${config.sops.templates."ialarm-config.yaml".path}:/config/config.yaml:ro"
      ];
    };
  };
}
