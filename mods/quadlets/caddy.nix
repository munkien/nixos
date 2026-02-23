{ config, ... }:

{
  users.users.caddy.extraGroups = [ "acme" ];

  services.caddy = {
    enable = true;
    logFormat = "format json { time_format iso8601 }";
    globalConfig = "servers { trusted_proxies static private_ranges }";

    extraConfig = ''
      (secure_proxy) {
        encode zstd gzip
        header Strict-Transport-Security "max-age=31536000;"
        header X-Content-Type-Options "nosniff"
        header X-Frame-Options "DENY"
      }
    '';

    virtualHosts."munkie.dk" = {
      useACMEHost = "munkie.dk";
      extraConfig = ''
        import secure_proxy
        respond "Hello World!"
      '';
    };
  };
}
