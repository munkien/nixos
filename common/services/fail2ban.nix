{pkgs, ...}: {
  virtualisation.arion.projects.home-infra.settings.services.fail2ban.service = {
    image = "crazymax/fail2ban:latest";
    network_mode = "host";
    capabilities.NET_ADMIN = true;
    capabilities.NET_RAW = true;
    volumes = [
      "/var/log/caddy:/var/log/caddy:ro"
      "/var/lib/fail2ban:/data"
    ];
    restart = "always";
  };
}
