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
      enabled: true

    snapshots:
      enabled: true

    objects:
      track:
        - person
        - car
        - dog

    record:
      enabled: true
      retain:
        days: 3
        mode: all
      events:
        retain:
          default: 14
          mode: motion

    cameras:
      driveway:
        ffmpeg:
          inputs:
            # High-resolution main stream -> ONLY for recording
            - path: rtsp://{FRIGATE_DRIVEWAY_USER}:{FRIGATE_DRIVEWAY_PASS}@{FRIGATE_DRIVEWAY_IP}:554/live/ch00_0
              roles:
                - record
            # Low-resolution sub-stream (usually ch01_0 or similar) -> ONLY for detect
            - path: rtsp://{FRIGATE_DRIVEWAY_USER}:{FRIGATE_DRIVEWAY_PASS}@{FRIGATE_DRIVEWAY_IP}:554/live/ch01_0
              roles:
                - detect
        detect:
          enabled: true
          width: 1920
          height: 1080
          fps: 5
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
