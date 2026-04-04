{config, ...}: let
  secrets = config.age.secrets;
in {
  age.secrets."acme_env" = {
    file = ../../secrets/acme_env.age;
    owner = "acme";
    group = "acme";
  };

  systemd.tmpfiles.rules = [
    "d /persist/services/acme 0750 acme acme -"
  ];

  fileSystems."/var/lib/acme" = {
    device = "/persist/services/acme";
    options = ["bind" "nofail"];
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "munkien@gmail.com";
      group = "acme";
      environmentFile = secrets."acme_env".path;
      dnsProvider = "cloudflare";
      dnsPropagationCheck = true;
    };
    certs."munkie.dk" = {
      enableDebugLogs = true;
      domain = "munkie.dk";
      extraDomainNames = [
        "*.munkie.dk"
        "*.lan.munkie.dk"
      ];
      reloadServices = [
        "pihole"
        "caddy"
        "frigate"
        "pocketid"
      ];
    };
  };
}
