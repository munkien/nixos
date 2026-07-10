{
  config,
  pkgs,
  ...
}: let
  frigateYaml = pkgs.writeText "frigate-config.yml" ''
    mqtt:
      host: home-server-1.home.arpa

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
            - path: rtsp://{FRIGATE_DRIVEWAY_USER}:{FRIGATE_DRIVEWAY_PASS}@{FRIGATE_DRIVEWAY_IP}:554/live/ch00_0
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
            - path: rtsp://{FRIGATE_ATTIC1_USER}:{FRIGATE_ATTIC1_PASS}@{FRIGATE_ATTIC1_IP}:554/live/ch00_0
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

  networking.firewall.allowedTCPPorts = [5000];
  networking.firewall.allowedUDPPorts = [5000 8554];

  age.secrets."frigate" = {
    rekeyFile = ../../secrets/services/frigate.age;
    mode = "0400";
  };

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
      # Mount the mutable file without the :ro flag
      "/var/lib/frigate/config/config.yml:/config/config.yml"
      "/var/lib/frigate/storage:/media/frigate"
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
