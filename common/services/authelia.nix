{pkgs, ...}: let
  autheliaConfig = pkgs.writeText "authelia-config.yml" ''
    theme: dark
    default_2fa_method: totp

    server:
      host: 0.0.0.0
      port: 9091

    log:
      level: info

    authentication_backend:
      file:
        path: /config/users_database.yml

    session:
      name: authelia_session
      domain: munkie.dk  # Your root domain

    storage:
      local:
        path: /config/db.sqlite3

    access_control:
      default_policy: deny
      rules:
        # Require two-factor auth for everything by default
        - domain: "*.munkie.dk"
          policy: two_factor
  '';
in {
  system.activationScripts.autheliaConfig = ''
    mkdir -p /var/lib/authelia
    cp -f ${autheliaConfig} /var/lib/authelia/configuration.yml
    chmod 0644 /var/lib/authelia/configuration.yml
  '';

  networking.firewall.allowedUDPPorts = [9091];
  networking.firewall.allowedTCPPorts = [9091];

  virtualisation.arion.projects.home-infra.settings.services.authelia.service = {
    image = "authelia/authelia:latest";
    container_name = "authelia";

    volumes = [
      "/var/lib/authelia:/config"
      "/etc/localtime:/etc/localtime:ro"
    ];

    # Needs to see the network to talk to Caddy
    network_mode = "host";
    restart = "always";
  };
}
