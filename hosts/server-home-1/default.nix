{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/common/default.nix
    ../../roles/server.nix

    # Services
    ../../modules/services/quadlet.nix
    ../../modules/services/acme.nix
    ../../modules/services/frigate.nix

    ../../modules/services/authelia.nix
    ../../modules/services/caddy.nix

    #../../mods/services/ebusd.nix

    #../../mods/services/homeassistant.nix
    #../../mods/services/ialarm-mqtt.nix
    #../../mods/services/mosquitto.nix
    #../../mods/services/omada.nix
    #../../mods/services/paperless-ngx.nix
    #../../mods/services/pihole.nix
    #../../mods/services/zigbee2mqtt.nix
  ];

  # Options
  my.impermanence.enable = true;
  my.autoUpgrade = {
    enable = true;
    flake = "github:munkien/nixos#server-home-1";
  };

  # Sleep and hibernation
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Naming
  networking.hostName = "server-home-1";
}
