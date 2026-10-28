{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../users/munkien
    ./filesystem.nix

    # Services
    ../../common/services/arion.nix
    ../../common/services/caddy.nix
    ../../common/services/fail2ban.nix
    ../../common/services/frigate.nix
    ../../common/services/glances.nix
    ../../common/services/omada.nix
    ../../common/services/homeassistant.nix
    ../../common/services/authelia.nix
    ../../common/services/mosquitto.nix
    ../../common/services/ebusd.nix
    ../../common/services/zigbee2mqtt.nix
    ../../common/services/ialarm2mqtt.nix
    ../../common/services/matterjs-server.nix
    ../../common/services/gatus.nix
  ];

  system.stateVersion = "26.11";

  my = {
    desktop.enable = false;
    gaming.enable = false;
    healthCheck.enable = true;
    containers.user = "munkien";
    flakeDir = "/home/munkien/nixos";

    # How each service is reachable. This is the single place exposure is
    # declared; the service modules hold only configuration.
    services = {
      # --- reverse-proxied by Caddy ---
      homeassistant = {
        ports = [8123];
        hostname = "ha.munkie.dk";
        proxyPort = 8123;
      };
      frigate = {
        # 8554 is the RTSP restream; 1984 is go2rtc.
        ports = [5000 8554 1984];
        hostname = "frigate.munkie.dk";
        proxyPort = 5000;
      };

      # --- LAN only ---
      gatus.ports = [8080];
      authelia.ports = [9091]; # HTTP only; 9091 is not a UDP service
      mosquitto.ports = [1883];
      zigbee2mqtt.ports = [8321];
      omada = {
        ports = [
          8088 # HTTP Web UI
          8043 # HTTPS Web UI
          8843 # Guest Portal HTTPS
          29811 # Management / Discovery
          29812 # Adoption / Management
          29813 # Firmware Upgrade
          29814 # Management
          29815 # Device Mgmt
          29816 # Device Mgmt
          29817 # Device Mgmt
        ];
        udpPorts = [
          29810 # Device Discovery
        ];
      };
    };
  };

  services.comin.enable = true;

  hardware = {
    facter = {
      enable = true;
      reportPath = ./facter.json;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  age.rekey.hostPubkey = lib.strings.trim (builtins.readFile ./hostPubkey.pub);

  # Sleep and hibernation
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
  # networking.hostName is set by flake-parts/hosts.nix from the directory name.
}
