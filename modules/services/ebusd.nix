{
  config,
  lib,
  ...
}: let
  common = import ./_base-quadlet.nix {inherit lib config;};
  persistDir =
    if config.my.impermanence.enable
    then "${config.my.impermanence.persistPath}/services/ebusd"
    else "/var/lib/ebusd";
in {
  options.my.services.ebusd.enable = lib.mkEnableOption "ebusd";
  config = lib.mkIf config.my.services.ebusd.enable {
    systemd.tmpfiles.rules = [
      "d ${persistDir} 0755 root root -"
    ];

    virtualisation.quadlet.containers.ebusd = lib.recursiveUpdate common {
      containerConfig = {
        # Pinned image version to ensure declarative and reproducible builds
        image = "docker.io/john30/ebusd:23.3";

        healthCmd = "ebusctl info";
        networks = ["host"];

        # Map the persistent directory so downloaded configs survive reboots
        volumes = [
          "${persistDir}:/var/lib/ebusd:rw"
        ];

        exec = [
          "ebusd"
          "-f"
          "-d"
          "ens:192.168.0.250:9999"
          "--scanconfig"
          "--mqttport=1883"
          "--mqttjson"
          "--mqtthost=127.0.0.1"
        ];

        # Retained volatile paths, removed /var/lib/ebusd
        tmpfses = [
          "/tmp"
          "/var/run"
          "/var/log"
        ];
      };
    };
  };
}
