{
  config,
  pkgs,
  lib,
  ...
}: {
  # Structure
  imports = [
    ../common.nix
    ../../mods/system/secrets.nix
    ../../mods/system/impermanence.nix

    # Services
    ../../mods/services/quadlet.nix

    ../../mods/services/acme.nix
    ../../mods/services/authelia.nix
    ../../mods/services/caddy.nix
    #../../mods/services/ebusd.nix
    #../../mods/services/frigate.nix
    #../../mods/services/homeassistant.nix
    #../../mods/services/ialarm-mqtt.nix
    #../../mods/services/mosquitto.nix
    ../../mods/services/omada.nix
    #../../mods/services/paperless-ngx.nix
    ../../mods/services/pihole.nix
    #../../mods/services/zigbee2mqtt.nix
  ];

  # Sleep and hibernation
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Naming
  networking.hostName = "server-home-1";
}
