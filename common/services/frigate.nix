{pkgs, ...}: {
  virtualisation.arion.projects.home-infra.settings.services.frigate.service = {
    image = "ghcr.io/blakeblackshear/frigate:stable";
    privileged = true;
    volumes = [
      "/etc/frigate/config.yml:/config/config.yml:ro"
      "/var/lib/frigate/storage:/media/frigate"
      "/etc/localtime:/etc/localtime:ro"
    ];
    ports = [
      "8554:8554"
    ];
    networks = ["internal_net"];
    restart = "always";
  };

  services.caddy.virtualHosts."frigate.munkie.dk" = {
    extraConfig = ''
      tls {
        dns cloudflare 123
      }
      reverse_proxy 127.0.0.1:5000
    '';
  };
}
