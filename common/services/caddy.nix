{
  config,
  pkgs,
  ...
}: {
  services.caddy = {
    enable = true;

    globalConfig = ''
      debug
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
    hash = "sha256-pB7YlSeVXyYahCDYKDmEtY39Wtr0kKWd1w2Bs2qMEfY=";
  };
}
