{lib, ...}: let
  # Camera defaults, so the three cameras do not repeat the same four settings.
  cameraDefaults = {
    detect = {
      width = 1920;
      height = 1080;
      fps = 5;
    };
    objects.track = ["person" "car" "dog"];
  };

  # Merge a camera's own settings over the defaults. Recursive, so setting only
  # `detect.fps` keeps the default width, height and fps.
  camera = settings: lib.recursiveUpdate cameraDefaults settings;

  # RTSP paths come from an age-encrypted env_file at runtime, so they cannot be
  # known to Nix. Frigate substitutes these itself, which is why they keep
  # single braces rather than Nix interpolation.
  secret = name: "{${name}}";

  drivewayUrl =
    "rtsp://{FRIGATE_DRIVEWAY_USER}:{FRIGATE_DRIVEWAY_PASS}"
    + "@{FRIGATE_DRIVEWAY_IP}:554/live/ch00_0";
in {
  options.my.frigateSettings = lib.mkOption {
    type = lib.types.attrs;
    description = "Frigate settings as attrsets; rendered to config.yml by frigate.nix.";
  };

  # Rendered to frigate's config.yml by the service module.
  config.my.frigateSettings = {
    mqtt = {
      enabled = true;
      host = "server-home-1.home.arpa";
      client_id = "frigate";
    };

    ffmpeg.hwaccel_args = "preset-vaapi";

    detect.enabled = true;
    snapshots.enabled = true;

    record = {
      enabled = true;
      continuous.days = 3;
      alerts.retain = {
        days = 14;
        mode = "motion";
      };
      detections.retain = {
        days = 14;
        mode = "motion";
      };
    };

    cameras = {
      driveway = camera {
        ffmpeg.inputs = [
          {
            path = drivewayUrl;
            roles = ["record" "detect"];
          }
        ];
        zones.actual_driveway = {
          coordinates = "0.043,0.383,0.696,0.584,0.702,0.721,0.853,0.736,0.898,0.658,0.947,0.65,0.926,0.998,0.006,0.997,0.005,0.418";
          loitering_time = 0;
          friendly_name = "Actual Driveway";
        };
        review.alerts.required_zones = "actual_driveway";
      };

      garage = camera {
        ffmpeg.inputs = [
          {
            path = secret "FRIGATE_GARAGE_PATH";
            roles = ["record" "detect"];
          }
        ];
      };

      attic1 = camera {
        ffmpeg.inputs = [
          {
            path = secret "FRIGATE_ATTIC1_PATH";
            roles = ["record" "detect"];
          }
        ];
        objects.track = ["bird" "cat" "mouse"];
      };
    };
  };
}
