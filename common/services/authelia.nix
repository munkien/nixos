{
  config,
  pkgs,
  ...
}: let
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
      domain: munkie.dk

    storage:
      local:
        path: /config/db.sqlite3

    access_control:
      default_policy: deny
      rules:
        - domain: "*.munkie.dk"
          policy: two_factor
  '';
in {
  # 1. Guarantee the config directory exists before mounting
  systemd.tmpfiles.rules = [
    "d /var/lib/authelia 0755 root root -"
  ];

  # 2. Deploy static config
  system.activationScripts.autheliaConfig = ''
    cp -f ${autheliaConfig} /var/lib/authelia/configuration.yml
    chmod 0644 /var/lib/authelia/configuration.yml
  '';

  networking.firewall.allowedUDPPorts = [9091];
  networking.firewall.allowedTCPPorts = [9091];

  # 3. Environment variables secret (auto-generated)
  age.secrets."authelia_env" = {
    rekeyFile = ../../secrets/services/authelia_env.age;
    mode = "0400";
    generator.script = {pkgs, ...}: ''
      echo "AUTHELIA_JWT_SECRET=$(${pkgs.openssl}/bin/openssl rand -hex 64)"
      echo "AUTHELIA_SESSION_SECRET=$(${pkgs.openssl}/bin/openssl rand -hex 64)"
      echo "AUTHELIA_STORAGE_ENCRYPTION_KEY=$(${pkgs.openssl}/bin/openssl rand -hex 64)"
    '';
  };

  # 4. Users database secret (manually managed)
  age.secrets."authelia_users" = {
    rekeyFile = ../../secrets/services/authelia_users.age;
    mode = "0400";
  };

  virtualisation.arion.projects.home-infra.settings.services.authelia.service = {
    image = "authelia/authelia:latest";
    container_name = "authelia";

    volumes = [
      "/var/lib/authelia:/config"
      # Bind the securely decrypted users file directly into the container
      "${config.age.secrets."authelia_users".path}:/config/users_database.yml:ro"
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
