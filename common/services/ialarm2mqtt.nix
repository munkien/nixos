{
  config,
  pkgs,
  ...
}: {
  age.secrets.ialarm2mqtt-config = {
    rekeyFile = ../../secrets/services/ialarm2mqtt.age;
    mode = "0444";
  };

  virtualisation.arion.projects.home-infra.settings.services.ialarm2mqtt.service = {
    image = "docker.io/maxill1/ialarm-mqtt:v0.12.0";
    container_name = "ialarm2mqtt";

    volumes = [
      "${config.age.secrets.ialarm2mqtt-config.path}:/config/config.yaml:ro"
    ];
  };
}
