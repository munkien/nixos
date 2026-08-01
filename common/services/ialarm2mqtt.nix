{
  config,
  pkgs,
  ...
}: {
  systemd.services.agenix = {
    unitConfig = {
      after = ["persist.mount"];
      requires = ["persist.mount"];
      wantedBy = ["multi-user.target"];
    };
  };

  age.secrets.ialarm-config = {
    rekeyFile = ../../secrets/services/ialarm2mqtt.age;
    symlink = false;
    mode = "0444";
  };

  virtualisation.arion.projects.home-infra.settings.services.ialarm2mqtt.service = {
    image = "docker.io/maxill1/ialarm-mqtt:v0.12.0";
    container_name = "ialarm2mqtt";

    volumes = [
      "${config.age.secrets.ialarm-config.path}:/config/config.json:ro"
    ];
  };
}
