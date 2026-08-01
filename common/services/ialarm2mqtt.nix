{
  config,
  pkgs,
  ...
}: let
  # Generate a proper JSON config file declaratively in the Nix store
  ialarmConfigJson = pkgs.writeText "config.json" (builtins.toJSON {
    mqtt = {
      host = "";
      port = 18034;
    };
  });
in {
  systemd.services.arion-home-infra = {
    wants = ["agenix.service"];
    after = ["agenix.service"];
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
      "${ialarmConfigJson}:/config/config.json:ro"
    ];

    restart = "always";
  };
}
