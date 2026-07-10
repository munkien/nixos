{pkgs, ...}: {
  # 1. Enable the native NixOS Fail2ban service
  services.fail2ban = {
    enable = true;

    # Never ban your own local networks
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "192.168.0.0/16"
    ];

    # 2. Define the jail targeting your Caddy logs
    jails.caddy = {
      settings = {
        enabled = true;
        port = "http,https";
        filter = "caddy-custom";
        logpath = "/var/log/caddy/*.log";
        maxretry = 5;
        findtime = 600;
        bantime = 3600;
      };
    };
  };

  # 3. Declaratively create the regex filter for Caddy
  # This catches 401, 403, 404, and 429 HTTP errors in Caddy's JSON logs
  environment.etc."fail2ban/filter.d/caddy-custom.conf".text = ''
    [Definition]
    failregex = ^.*"remote_ip":"<HOST>".*"status":(?:401|403|404|429).*$
    ignoreregex =
  '';
}
