{
  config,
  pkgs,
  ...
}: let
  autheliaConfig = pkgs.writeText "authelia-config.yml" ''
    theme: dark
    default_2fa_method: totp

    server:
      address: 'tcp://0.0.0.0:9091'

    log:
      level: info

    authentication_backend:
      file:
        path: /secrets/users_database.yml

    session:
      cookies:
        - name: 'authelia_session'
          domain: 'munkie.dk'
          authelia_url: 'https://authelia.munkie.dk'
          expiration: '1 hour'
          inactivity: '5 minutes'
        - name: 'authelia_session'
          domain: 'server-home-1.home.arpa'
          authelia_url: 'http://server-home-1.home.arpa'
          expiration: '1 hour'
          inactivity: '5 minutes'
          insecure: true

    storage:
      local:
        path: /config/db.sqlite3

    notifier:
      filesystem:
        filename: /config/notifications.txt

    access_control:
      default_policy: deny
      rules:
        - domain: "*.munkie.dk"
          policy: two_factor
  '';
in {
  systemd.tmpfiles.rules = [
    "d /var/lib/authelia 0755 root root -"
  ];

  preservation.preserveAt."/persist" = {
    directories = [
      "/var/lib/authelia"
    ];
  };

  system.activationScripts.autheliaConfig = ''
    cp -f ${autheliaConfig} /var/lib/authelia/configuration.yml
    chmod 0644 /var/lib/authelia/configuration.yml
  '';

  networking.firewall.allowedUDPPorts = [9091];
  networking.firewall.allowedTCPPorts = [9091];

  age.secrets."authelia_env" = {
    rekeyFile = ../../secrets/services/authelia_env.age;
    mode = "0400";
    generator.script = {pkgs, ...}: ''
      # Updated the JWT variable name to match v4.38+ requirements
      echo "AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET=$(${pkgs.openssl}/bin/openssl rand -hex 64)"
      echo "AUTHELIA_SESSION_SECRET=$(${pkgs.openssl}/bin/openssl rand -hex 64)"
      echo "AUTHELIA_STORAGE_ENCRYPTION_KEY=$(${pkgs.openssl}/bin/openssl rand -hex 64)"
    '';
  };

  age.secrets."authelia_users" = {
    rekeyFile = ../../secrets/services/authelia_users.age;
    mode = "0400";
  };

  virtualisation.arion.projects.home-infra.settings.services.authelia.service = {
    image = "authelia/authelia:latest";
    container_name = "authelia";

    volumes = [
      "/var/lib/authelia:/config"
      # Mount the immutable secret to a separate path to bypass the chown failure
      "${config.age.secrets."authelia_users".path}:/secrets/users_database.yml:ro"
      "/etc/localtime:/etc/localtime:ro"
    ];

    env_file = [
      config.age.secrets."authelia_env".path
    ];

    ports = [
      "9091:9091"
    ];

    restart = "always";
  };
}
