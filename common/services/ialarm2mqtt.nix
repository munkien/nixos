{
  config,
  pkgs,
  ...
}: {
  # This assumes you have encrypted your complete config.yaml into this .age file
  age.secrets.ialarm-config = {
    rekeyFile = ../../secrets/services/ialarm2mqtt.age;
    symlink = false;
    mode = "0444";
  };

  # 2. Bind-mount the decrypted path into your Arion project
  virtualisation.arion.projects.home-infra.settings.services.ialarm2mqtt.service = {
    image = "ghcr.io/maxill1/ialarm-mqtt:latest";
    container_name = "ialarm2mqtt";

    volumes = [
      "${config.age.secrets.ialarm-config.path}:/config/config.yaml:ro"
    ];

    restart = "always";
  };
}
