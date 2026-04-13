{lib, ...}: let
  common = import ./base-quadlet.nix {inherit lib;};
  domain = "munkie.dk";
  appUrl = "homeassistant.lan.${domain}";
  port = 8123;
  persistDir = "/persist/services/homeassistant";
in {
  # Declaratively ensure state directories exist
  systemd.tmpfiles.rules = [
    "d ${persistDir} 0755 root root -"
    "d ${persistDir}/varlib 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [port];

  services.caddy.virtualHosts."${appUrl}" = {
    useACMEHost = domain;
    extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
  };

  # Declaratively enable Bluetooth on the host for D-Bus passthrough
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  virtualisation.quadlet.containers.homeassistant = lib.recursiveUpdate common {
    containerConfig = {
      image = "ghcr.io/home-assistant/home-assistant:2025.12";

      # Use persistent device IDs, mapping them to the expected internal path
      devices = [
        # UPDATE THIS PATH: "ls -l /dev/serial/by-id/" to find your dongle
        "/dev/serial/by-id/usb-YOUR_ZIGBEE_OR_ZWAVE_DONGLE_ID-if00-port0:/dev/ttyUSB0"
      ];

      addCapabilities = [
        "CAP_NET_RAW"
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
      ];

      networks = ["host"];

      healthCmd = "curl --fail http://127.0.0.1:${toString port} || exit 1";

      annotations = {
        "run.oci.keep_original_groups" = "true";
      };

      environments = {
        PYTHONPATH = "/config/deps";
        PIP_TARGET = "/config/deps";
      };

      tmpfses = [
        "/tmp"
        "/run"
      ];

      volumes = [
        "${persistDir}:/config:rw,Z,U"
        "${persistDir}/varlib:/var/lib/homeassistant:rw,Z,U"
        # Note: If this media dir is shared with Frigate, use 'z' (lowercase) instead of 'Z'
        "/mnt/media/homeassistant:/media:rw,z,U"
        "/sys:/sys:ro"
        "/run/dbus:/run/dbus:ro"
      ];
    };
  };
}
