{lib, ...}: let
  common = import ./base-quadlet.nix {inherit lib;};
  domain = "munkie.dk";
  appUrl = "paperless.lan.${domain}";
  authUrl = "id.lan.${domain}";
  persistDir = "/persist/services/paperless-ngx";
  paperlessPort = 28981;
in {
  # Declaratively create directories with correct ownership for the dynamic user
  systemd.tmpfiles.rules = [
    "d ${persistDir} 0750 paperless paperless - -"
    "d ${persistDir}/data 0750 paperless paperless - -"
    "d ${persistDir}/media 0750 paperless paperless - -"
    "d ${persistDir}/consume 0770 paperless paperless - -"
  ];

  services.redis.servers."paperless" = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";
  };

  services.caddy.virtualHosts."${appUrl}" = {
    useACMEHost = domain;
    extraConfig = ''
      forward_auth 127.0.0.1:9091 {
          uri /api/verify?rd=https://${authUrl}/
          copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:${toString paperlessPort}
    '';
  };

  services.paperless = {
    enable = true;

    # Use native NixOS module properties instead of manual env vars
    address = "127.0.0.1";
    port = paperlessPort;
    dataDir = "${persistDir}/data";
    mediaDir = "${persistDir}/media";
    consumptionDir = "${persistDir}/consume";
    consumptionDirIsPublic = true;

    settings = {
      PAPERLESS_URL = "https://${appUrl}";
      PAPERLESS_ALLOWED_HOSTS = appUrl;
      PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://${appUrl}";

      PAPERLESS_REDIS = "redis://127.0.0.1:6379";

      PAPERLESS_OCR_LANGUAGE = "dan+eng";
      PAPERLESS_OCR_LANGUAGES = "dan eng";

      PAPERLESS_TIKA_ENABLED = true;
      PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:9998";

      # FIXED: Aligned Gotenberg port to match the Quadlet output (3044)
      PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:3044";
    };
  };

  virtualisation.quadlet.containers.tika = lib.recursiveUpdate common {
    containerConfig = {
      # Pinned for reproducibility
      image = "docker.io/apache/tika:2.9.2.1";

      # Fixed healthcheck to test the actual HTTP endpoint instead of a raw bash TCP echo
      healthCmd = "curl -f http://127.0.0.1:9998/tika || exit 1";
      publishPorts = ["127.0.0.1:9998:9998"];
      tmpfses = ["/tmp" "/var/run"];
    };
  };

  virtualisation.quadlet.containers.gotenberg = lib.recursiveUpdate common {
    containerConfig = {
      # Pinned for reproducibility
      image = "docker.io/gotenberg/gotenberg:8.13.2";

      healthCmd = "curl -f http://127.0.0.1:3000/health || exit 1";
      publishPorts = ["127.0.0.1:3044:3000"];
      tmpfses = ["/tmp" "/var/run"];
    };
  };

  # The manual systemd.services.* blocks were completely removed.
  # Using the native dataDir/mediaDir options automatically instructs NixOS
  # to grant the correct ReadWritePaths to the sandboxed systemd services.
}
