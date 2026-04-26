{
  config,
  lib,
  inputs,
  ...
}: let
  domain = "munkie.dk";
  persistDir = "${config.my.impermanence.persistPath}/services/acme";
in {
  options.my.services.acme.enable = lib.mkEnableOption "ACME certificate management";

  config = lib.mkIf config.my.services.acme.enable {
    age.secrets.acme-env = {
      rekeyFile = inputs.self + "/secrets/services/acme/env.age";
      owner = "acme";
      group = "acme";
      mode = "0400";
    };

    systemd.tmpfiles.rules =
      lib.optional config.my.impermanence.enable
      "d ${persistDir} 0750 acme acme -";

    # Bind-mount the persist directory over the ephemeral /var/lib/acme so
    # certificates survive reboots on impermanence setups.
    fileSystems = lib.optionalAttrs config.my.impermanence.enable {
      "/var/lib/acme" = {
        device = persistDir;
        fsType = "none";
        options = ["bind" "nofail"];
      };
    };

    security.acme = {
      acceptTerms = true;

      defaults = {
        email = "munkien@gmail.com";
        group = "acme";
        environmentFile = config.age.secrets.acme-env.path;
        dnsProvider = "cloudflare";
        dnsPropagationCheck = true;
      };

      certs.${domain} = {
        # Wildcard covers all subdomains; LAN wildcard covers internal hosts.
        extraDomainNames = [
          "*.${domain}"
          "*.lan.${domain}"
        ];

        reloadServices = [
          "caddy.service"
          "podman-frigate.service"
          "podman-pihole.service"
        ];
      };
    };
  };
}
