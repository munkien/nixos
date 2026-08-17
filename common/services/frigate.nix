{
  config,
  pkgs,
  ...
}: let
  frigateYaml = pkgs.writeText "frigate-config.yml" ''
    mqtt:
      enabled: True
      host: server-home-1.home.arpa
      client_id: frigate

    ffmpeg:
      hwaccel_args: preset-vaapi

    detect:
      enabled: True

    snapshots:
      enabled: True

    record:
      enabled: True

      continuous:
        days: 3

      alerts:
        retain:
          days: 14
          mode: motion

      detections:
        retain:
          days: 14
          mode: motion

    cameras:
      driveway:
        ffmpeg:
          inputs:
            - path: "rtsp://{FRIGATE_DRIVEWAY_USER}:{FRIGATE_DRIVEWAY_PASS}@{FRIGATE_DRIVEWAY_IP}:554/live/ch00_0" # /LowResolutionVideo
              roles:
                - record
                - detect
        detect:
          width: 1920
          height: 1080
          fps: 5
        objects:
          track:
            - person
            - car
            - dog
        zones:
          actual_driveway:
            coordinates:
              0.043,0.383,0.696,0.584,0.702,0.721,0.853,0.736,0.898,0.658,0.947,0.65,0.926,0.998,0.006,0.997,0.005,0.418
            loitering_time: 0
            friendly_name: Actual Driveway
        review:
          alerts:
            required_zones: actual_driveway

      garage:
        ffmpeg:
          inputs:
            - path: "{FRIGATE_GARAGE_PATH}"
              roles:
                - record
                - detect
        detect:
          width: 1920
          height: 1080
          fps: 5
        objects:
          track:
            - person
            - car
            - dog

      attic1:
        ffmpeg:
          inputs:
            - path: "{FRIGATE_ATTIC1_PATH}"
              roles:
                - record
                - detect
        detect:
          width: 1920
          height: 1080
          fps: 5
        objects:
          track:
            - bird
            - cat
            - mouse
  '';
in {
  system.activationScripts.frigateConfig = ''
    mkdir -p /var/lib/frigate/config
    cp -f ${frigateYaml} /var/lib/frigate/config/config.yml
    chmod 0644 /var/lib/frigate/config/config.yml
  '';

  networking.firewall.allowedTCPPorts = [5000 8554 1984];
  networking.firewall.allowedUDPPorts = [5000 8554 1984];

  age.secrets."frigate" = {
    rekeyFile = ../../secrets/services/frigate.age;
    mode = "0400";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/frigate/shm 1777 root root -"
    "d /var/lib/frigate/config 0755 root root -"
    "d /var/lib/frigate/storage 0755 root root -"
  ];
  systemd.mounts = [
    {
      what = "tmpfs";
      where = "/var/lib/frigate/shm";
      type = "tmpfs";
      options = "size=1G,mode=1777";
    }
  ];

  virtualisation.arion.projects.home-infra.settings.services.frigate.service = {
    image = "ghcr.io/blakeblackshear/frigate:stable";
    privileged = true;
    devices = [
      "/dev/dri/renderD128:/dev/dri/renderD128"
    ];
    volumes = [
      "/var/lib/frigate/config:/config"
      "/media/frigate:/media/frigate"
      "/etc/localtime:/etc/localtime:ro"
      "/var/lib/frigate/shm:/dev/shm"
    ];
    env_file = [
      config.age.secrets."frigate".path
    ];
    ports = [
      "8554:8554"
      "5000:5000"
    ];
    networks = ["internal_net"];
    restart = "always";
  };

  services.caddy.virtualHosts."frigate.munkie.dk" = {
    extraConfig = ''
      reverse_proxy 127.0.0.1:5000
    '';
  };
}
