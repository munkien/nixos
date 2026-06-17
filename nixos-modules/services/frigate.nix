_: {
  services.frigate = {
    enable = true;
    hostname = "frigate.home.arpa";

    settings = {
      mqtt = {
        host = "mqtt.home.arpa";
        topic_prefix = "frigate";
      };

      go2rtc = {
        streams = {
          driveway_main = "rtsp://admin:xq7KGsd5eacdly@camera.home.arpa:554/";
        };
      };

      cameras = {
        driveway = {
          ffmpeg = {
            inputs = [
              {
                # Point to the local go2rtc main stream for recording
                path = "rtsp://127.0.0.1:8554/driveway_main";
                roles = ["record" "detect"];
              }
            ];
          };
          detect = {
            enabled = true;
            width = 640;
            height = 480;
          };
        };
      };
    };
  };
}
