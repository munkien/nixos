{pkgs, ...}: {
  system.activationScripts.omadaDirs = ''
    mkdir -p /var/lib/omada/{data,work,logs}
  '';

  virtualisation.arion.projects.home-infra.settings.services.omada.service = {
    image = "mbentley/omada-controller:6.2";
    container_name = "omada-controller";

    environment = {
      TZ = "Europe/Copenhagen";
      SHOW_SERVER_LOGS = "true";
      SHOW_MONGODB_LOGS = "false";
    };

    volumes = [
      "/var/lib/omada/data:/opt/tplink/EAPController/data"
      "/var/lib/omada/work:/opt/tplink/EAPController/work"
      "/var/lib/omada/logs:/opt/tplink/EAPController/logs"
      "/etc/localtime:/etc/localtime:ro"
    ];

    network_mode = "host";
    stop_grace_period = "60s";
    restart = "always";
  };
}
