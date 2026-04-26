{
  config,
  lib,
  inputs,
  ...
}: let
  domain = "munkie.dk";
  appUrl = "id.lan.${domain}";
  listenAddr = "127.0.0.1";
  port = 9091;
  persistDir = "${config.my.impermanence.persistPath}/services/authelia";
in {
  options.my.services.authelia.enable = lib.mkEnableOption "Authelia SSO";

  config = lib.mkIf config.my.services.authelia.enable {
    assertions = [
      {
        assertion = config.services.caddy.enable or false;
        message = "Authelia requires Caddy to be enabled.";
      }
    ];

    age.secrets = {
      authelia-jwt-secret = {
        rekeyFile = inputs.self + "/secrets/services/authelia/jwt-secret.age";
        owner = "authelia-main";
        group = "authelia-main";
        mode = "0400";
      };
      authelia-session-secret = {
        rekeyFile = inputs.self + "/secrets/services/authelia/session-secret.age";
        owner = "authelia-main";
        group = "authelia-main";
        mode = "0400";
      };
      authelia-storage-encryption-key = {
        rekeyFile = inputs.self + "/secrets/services/authelia/storage-encryption-key.age";
        owner = "authelia-main";
        group = "authelia-main";
        mode = "0400";
      };
    };

    systemd.tmpfiles.rules =
      lib.optional config.my.impermanence.enable
      "d ${persistDir} 0750 authelia-main authelia-main -";

    fileSystems = lib.optionalAttrs config.my.impermanence.enable {
      "/var/lib/authelia-main" = {
        device = persistDir;
        fsType = "none";
        options = ["bind" "nofail"];
      };
    };

    services.caddy.virtualHosts.${appUrl} = {
      useACMEHost = domain;
      extraConfig = "reverse_proxy ${listenAddr}:${toString port}";
    };

    services.authelia.instances.main = {
      enable = true;

      secrets = {
        jwtSecretFile = config.age.secrets.authelia-jwt-secret.path;
        sessionSecretFile = config.age.secrets.authelia-session-secret.path;
        storageEncryptionKeyFile = config.age.secrets.authelia-storage-encryption-key.path;
      };

      settings = {
        theme = "dark";

        server.address = "tcp://${listenAddr}:${toString port}";

        # TOTP issuer shown in authenticator apps — use the bare domain, not the URL.
        totp.issuer = domain;

        webauthn.enable_passkey_login = true;

        authentication_backend = {
          password_reset.disable = true;
          file = {
            path = "/var/lib/authelia-main/users.yaml";
            watch = true;
            search.email = true;
          };
        };

        session = {
          cookies = [
            {
              inherit domain;
              subdomain = "id.lan";
              authelia_url = "https://${appUrl}";
              # Allow SSO across all subdomains on the domain.
              default_redirection_url = "https://${domain}";
            }
          ];
        };

        # Filesystem notifier writes emails to a file instead of sending them.
        # Switch to an smtp notifier when email delivery is needed.
        notifier.filesystem.filename = "/var/lib/authelia-main/notifications.txt";

        storage.local.path = "/var/lib/authelia-main/db.sqlite3";

        access_control = {
          default_policy = "deny";
          rules = [
            {
              domain = "*.lan.${domain}";
              policy = "two_factor";
            }
          ];
        };

        telemetry.metrics = {
          enabled = true;
          # Metrics are served on port 9959 on localhost only.
          address = "tcp://127.0.0.1:9959";
        };
      };
    };
  };
}
