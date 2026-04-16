{
  config,
  lib,
  ...
}: let
  domain = "munkie.dk";
  persistDir = "/persist/services/acme";
in {
  options.my.services.acme.enable = lib.mkEnableOption "ACME certificate management";

  config = lib.mkIf config.my.services.acme.enable {
    age.secrets.acme-env = {
      rekeyFile = ../../secrets/services/acme/env.age;
      owner = "acme";
      group = "acme";
      mode = "0400";
    };

    systemd.tmpfiles.rules = [
      "d ${persistDir} 0750 acme acme -"
    ];

    # Bind-mount the persist directory over the ephemeral /var/lib/acme so
    # certificates survive reboots on impermanence setups.
    fileSystems."/var/lib/acme" = {
      device = persistDir;
      options = ["bind" "nofail"];
    };

    security.acme = {
      acceptTerms = true;

      defaults = {
        email = "munkien@gmail.com";
        group = "acme";
        environmentFile = config.age.secrets.acme-env.path;
        dnsProvider = "cloudflare";
        # Wait for DNS propagation before completing the challenge (default: true).
        dnsPropagationCheck = true;
      };

      certs.${domain} = {
        # Wildcard covers all subdomains; LAN wildcard covers internal hosts.
        extraDomainNames = [
          "*.${domain}"
          "*.lan.${domain}"
        ];

        # Reload services after certificate renewal so they pick up the new cert.
        # Quadlet containers are managed as podman-<name>.service.
        reloadServices = [
          "caddy.service"
          "podman-frigate.service"
          "podman-pihole.service"
        ];
      };
    };
  };
}
