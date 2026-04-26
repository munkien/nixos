{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  common = import ./_base-quadlet.nix {inherit lib config;};
  domain = "munkie.dk";
  appUrl = "frigate.lan.${domain}";
  authUrl = "id.lan.${domain}";
  persistDir =
    if config.my.impermanence.enable
    then "${config.my.impermanence.persistPath}/services/frigate"
    else "/var/lib/frigate";

  frigateConfig = {
    database.path = "/config/db/frigate.db";
    mqtt.host = "127.0.0.1";

    detectors.ov = {
      type = "openvino";
      device = "AUTO";
    };

    record = {
      enabled = true;

      continuous = {
        days = 3;
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

    go2rtc = {
      streams = {
        driveway = "rtsp://camera-driveway.home.arpa:554/user=admin_password={FRIGATE_CAMERA_DRIVEWAY_PASSWORD}_channel=0_stream=0&onvif=0.sdp?real_stream";
        south = "rtsp://camera-south.home.arpa:554/user=admin_password={FRIGATE_CAMERA_SOUTH_PASSWORD}_channel=0_stream=0&onvif=0.sdp?real_stream";
      };
    };

    cameras = {
      driveway = {
        ffmpeg.inputs = [
          {
            path = "rtsp://camera-driveway.home.arpa:554/user=admin_password={FRIGATE_CAMERA_DRIVEWAY_PASSWORD}_channel=0_stream=0&onvif=0.sdp?real_stream";
            roles = ["detect" "record"];
          }
        ];
        detect.enabled = true;
      };
      south = {
        ffmpeg.inputs = [
          {
            path = "rtsp://camera-south.home.arpa:554/user=admin_password={FRIGATE_CAMERA_SOUTH_PASSWORD}_channel=0_stream=0&onvif=0.sdp?real_stream";
            roles = ["detect" "record"];
          }
        ];
        detect.enabled = true;
      };
    };
  };

  yamlFormat = pkgs.formats.yaml {};
  frigateYamlFile = yamlFormat.generate "frigate.yml" frigateConfig;
in {
  options.my.services.frigate.enable = lib.mkEnableOption "Frigate NVR";

  config = lib.mkIf config.my.services.frigate.enable {
    assertions = [
      {
        assertion = config.services.caddy.enable or false;
        message = "Frigate requires Caddy to be enabled.";
      }
    ];

    age.secrets.frigate-env = {
      rekeyFile = inputs.self + "/secrets/services/frigate/env.age";
      owner = "root";
      mode = "0400";
    };

    systemd.tmpfiles.rules = [
      "d ${persistDir}        0755 root root -"
      "d ${persistDir}/media  0755 root root -"
      "d ${persistDir}/db     0755 root root -"
    ];

    # With host networking, the container shares the host's network stack, so
    # these ports are automatically accessible. Explicit rules are only needed
    # if you switch away from host networking in the future.
    networking.firewall = {
      allowedTCPPorts = [8554 8555];
      allowedUDPPorts = [8555];
    };

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

    virtualisation.quadlet.containers.frigate = lib.recursiveUpdate common {
      containerConfig = {
        # Frigate requires running as root for hardware access and s6 init.
        # This overrides the base userns = "auto" since they are incompatible.
        user = "root";
        userns = lib.mkForce "";

        image = "ghcr.io/blakeblackshear/frigate:0.17.1";

        shmSize = "1G";
        notify = false;

        # Host networking is required to reach RTSP cameras on the LAN and
        # to expose the RTSP re-stream (8554) and WebRTC (8555) without NAT.
        networks = lib.mkForce ["host"];

        # Frigate writes to /config, /media, and /tmp — cannot be read-only.
        readOnly = lib.mkForce false;

        # Minimal capabilities needed for hardware video decoding via iGPU.
        dropCapabilities = lib.mkForce ["ALL"];
        addCapabilities = ["CAP_CHOWN" "CAP_FOWNER" "CAP_SETGID" "CAP_SETUID"];

        devices = ["/dev/dri/renderD128"];

        healthCmd = "wget -qO- http://127.0.0.1:5000/api/version || exit 1";
        # Override the base 10s — Frigate takes 2–3 minutes to fully start.
        healthStartPeriod = lib.mkForce "3m";

        environments = {
          LIBVA_DRIVER_NAME = "i965";
        };
        environmentFiles = [config.age.secrets.frigate-env.path];

        volumes = [
          "${frigateYamlFile}:/config/config.yml:ro"
          "${persistDir}/db:/config/db:rw,U,Z"
          "${persistDir}/media:/media/frigate:rw,U,Z"
        ];
        mounts = [
          "type=tmpfs,destination=/tmp,tmpfs-mode=1777"
          "type=tmpfs,destination=/run,tmpfs-mode=1777"
        ];
      };
    };
  };
}
