{
  config,
  lib,
  pkgs,
  ...
}: let
  common = import ./base-quadlet.nix {inherit lib;};
  domain = "munkie.dk";
  appUrl = "frigate.lan.${domain}";
  authUrl = "id.lan.${domain}";
  persistDir = "/persist/services/frigate";

  frigateConfig = {
    version = "0.14-0"; # Aligned with the container image version

    database.path = "/config/db/frigate.db";

    mqtt.host = "127.0.0.1";

    detectors.ov = {
      type = "openvino";
      device = "AUTO";
    };

    record = {
      enabled = true;
      retain = {
        days = 3;
        mode = "all";
      };
      alerts.retain = {
        days = 30;
        mode = "motion";
      };
      detections.retain = {
        days = 7;
        mode = "motion";
      };
    };

    model = {
      width = 300;
      height = 300;
      input_tensor = "nhwc";
      input_pixel_format = "bgr";
      path = "/openvino-model/ssdlite_mobilenet_v2.xml";
      labelmap_path = "/openvino-model/coco_91cl_bkgr.txt";
    };

    cameras = {
      driveway = {
        ffmpeg.inputs = [
          {
            path = "rtsp://192.168.0.201:554/user=admin_password={CAMERA_DRIVEWAY_PASSWORD}_channel=0_stream=0&onvif=0.sdp?real_stream";
            roles = ["detect" "record"];
          }
        ];
        detect.enabled = true;
      };

      south = {
        ffmpeg.inputs = [
          {
            path = "rtsp://192.168.0.200:554/user=admin_password={CAMERA_SOUTH_PASSWORD}_channel=0_stream=0&onvif=0.sdp?real_stream";
            roles = ["detect" "record"];
          }
        ];
        detect.enabled = true;
      };
    };
  };

  # Generate the YAML file in the Nix store
  yamlFormat = pkgs.formats.yaml {};
  frigateYamlFile = yamlFormat.generate "frigate.yml" frigateConfig;
in {
  # Define the secret containing your environment variables
  sops.secrets."frigate_env" = {
    sopsFile = ../secrets/frigate.yaml;
  };

  # Declaratively create required state directories
  systemd.tmpfiles.rules = [
    "d ${persistDir}/media 0755 root root -"
    "d ${persistDir}/db 0755 root root -"
    "d ${persistDir}/letsencrypt 0755 root root -"
  ];

  networking.firewall = {
    allowedTCPPorts = [8554 8555];
    allowedUDPPorts = [8555];
  };

  # Caddy reverse proxy with Authelia forward authentication
  services.caddy.virtualHosts."${appUrl}" = {
    useACMEHost = domain;
    extraConfig = ''
      forward_auth 127.0.0.1:9091 {
          uri /api/verify?rd=https://${authUrl}/
          copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:5000
    '';
  };

  # Podman Quadlet definition
  virtualisation.quadlet.containers.frigate = lib.recursiveUpdate common {
    containerConfig = {
      user = "root";
      # Pin to a specific, reproducible tag
      image = "ghcr.io/blakeblackshear/frigate:0.14.1";
      shmSize = "1G";
      notify = false;
      networks = ["host"];
      readOnly = false;

      addCapabilities = [
        "CAP_CHOWN"
        "CAP_FOWNER"
        "CAP_DAC_OVERRIDE"
        "CAP_SYS_ADMIN"
      ];

      devices = ["/dev/dri/renderD128"];

      healthCmd = "wget -qO- http://127.0.0.1:5000/api/version || exit 1";
      healthStartPeriod = "3m";

      environments = {
        S6_READ_ONLY_ROOT = "1";
        # Change to "iHD" if using a Broadwell or newer Intel CPU
        LIBVA_DRIVER_NAME = "i965";
      };

      # Inject secrets via standard .env format
      environmentFiles = [
        config.sops.secrets."frigate_env".path
      ];

      volumes = [
        # Mount the Nix-generated config directly as read-only
        "${frigateYamlFile}:/config/config.yml:ro"
        "${persistDir}/db:/config/db:rw,U,Z"
        "/mnt/media:/media/frigate:rw,U,Z"
        "${persistDir}/letsencrypt:/etc/letsencrypt:rw,U,Z"
      ];

      mounts = [
        "type=tmpfs,destination=/tmp,tmpfs-mode=1777"
        "type=tmpfs,destination=/run,tmpfs-mode=1777"
      ];
    };
  };
}
