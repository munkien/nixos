{
  config,
  lib,
  ...
}:

let
  domain = "munkie.dk";
  appUrl = "id.lan.${domain}";
  listenAddr = "127.0.0.1";
  port = 9091;
  persistDir = "/persist/services/authelia";
in
{
  services.caddy.virtualHosts."${appUrl}" = {
    useACMEHost = domain;
    extraConfig = "reverse_proxy ${listenAddr}:${toString port}";
  };

  # Declaratively ensure the persistent directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d ${persistDir} 0750 authelia-main authelia-main - -"
  ];

  systemd.services.authelia-main.serviceConfig = {
    ReadWritePaths = [ persistDir ];
  };

  # DRY approach to applying repetitive SOPS attributes
  sops.secrets = lib.genAttrs [
    "AUTHELIA_JWT_SECRET"
    "AUTHELIA_SESSION_SECRET"
    "AUTHELIA_STORAGE_ENCRYPTION_KEY"
  ] (name: {
    sopsFile = ../secrets/authelia.yaml;
    owner = "authelia-main";
    group = "authelia-main";
  });

  services.authelia.instances.main = {
    enable = true;

    secrets = {
      jwtSecretFile = config.sops.secrets."AUTHELIA_JWT_SECRET".path;
      storageEncryptionKeyFile = config.sops.secrets."AUTHELIA_STORAGE_ENCRYPTION_KEY".path;
      sessionSecretFile = config.sops.secrets."AUTHELIA_SESSION_SECRET".path;
    };

    settings = {
      theme = "dark";
      telemetry.metrics.enabled = true;

      server.address = "tcp://${listenAddr}:${toString port}";
      totp.issuer = appUrl;

      webauthn = {
        enable_passkey_login = true;
      };

      authentication_backend = {
        password_reset.disable = true;

        file = {
          path = "${persistDir}/users.yaml";
          watch = true; # Corrected to boolean
          search.email = true;
        };
      };

      session.cookies = [
        {
          inherit domain;
          authelia_url = "https://${appUrl}";
        }
      ];

      notifier.filesystem.filename = "${persistDir}/notification.txt";
      storage.local.path = "${persistDir}/db.sqlite3";
      
      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = "*.${domain}";
            policy = "two_factor";
          }
        ];
      };
    };
  };
}
