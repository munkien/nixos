{
  config,
  pkgs,
  ...
}: {
  services.caddy = {
    enable = true;

    globalConfig = ''
      email me@example.com
      acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
    '';
  };

  age.secrets."caddy-env" = {
    rekeyFile = ../../secrets/services/caddy-env.age;
    mode = "0400";
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = config.age.secrets."caddy-env".path;

  services.caddy.package = pkgs.caddy.withPlugins {
    plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
    hash = "sha256-8yZDrejNKsaUnUaTUFYbarWNmxafqp2z2rWo+XRsxV8=";
  };
}
