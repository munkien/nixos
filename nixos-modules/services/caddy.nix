_: {
  services.caddy = {
    enable = true;

    # Authelia portal
    virtualHosts."auth.home.arpa" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:9091
      '';
    };

    virtualHosts."frigate.lan" = {
      extraConfig = ''
        forward_auth 127.0.0.1:9091 {
          uri /api/verify?rd=https://auth.home.arpa
          copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
        }
        reverse_proxy 127.0.0.1:5000
      '';
    };
  };
}
