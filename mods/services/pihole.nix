{
  config,
  lib,
  pkgs,
  ...
}: let
  common = import ./base-quadlet.nix {inherit lib config;};
  hostIp = "192.168.0.50";
in {
  # Secrets
  age.secrets."pihole_password" = {
    file = ../../secrets/secret_wifi_env.age;
    mode = "0440";
    group = "root"; # Podman/Docker running as root needs access
  };

  # Base directories
  systemd.tmpfiles.rules = map (d: "d /persist/services/pihole${d} 0755 root root -") ["" "/config"];

  # Automated Blocklist Updates
  systemd.timers."pihole-gravity-update" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
      RandomizedDelaySec = "60m";
      Persistent = true;
    };
  };

  systemd.services."pihole-gravity-update" = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      ${pkgs.podman}/bin/podman exec pihole true 2>/dev/null || exit 0

      echo "Injecting Hagezi blocklist..."
      ${pkgs.podman}/bin/podman exec pihole pihole-FTL sqlite3 /etc/pihole/gravity.db \
        "INSERT OR IGNORE INTO adlist (address, enabled, comment) VALUES ('https://codeberg.org/hagezi/mirror2/raw/branch/main/dns-blocklists/adblock/pro.txt', 1, 'Hagezi Pro via Nix');"

      echo "Updating Gravity..."
      ${pkgs.podman}/bin/podman exec pihole pihole -g
    '';
  };

  # Caddy Reverse Proxy
  services.caddy.virtualHosts."pi.lan.munkie.dk" = {
    useACMEHost = "munkie.dk";
    extraConfig = ''
      forward_auth 127.0.0.1:9091 {
          uri /api/verify?rd=https://id.lan.munkie.dk/
          copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
      }
      reverse_proxy 127.0.0.1:5380
    '';
  };

  # Host Networking & DNS Routing
  networking.firewall = {
    allowedTCPPorts = [53 8022];
    allowedUDPPorts = [53];
  };

  services.resolved.extraConfig = "DNSStubListener=no";
  services.resolved.enable = false;
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "default";

  networking.nameservers = [hostIp "1.1.1.1" "8.8.8.8"];
  networking.networkmanager.appendNameservers = [hostIp "1.1.1.1" "8.8.8.8" "8.8.4.4"];

  boot.kernel.sysctl = {
    "net.ipv4.ip_nonlocal_bind" = 1;
    "net.ipv4.ip_unprivileged_port_start" = 53;
  };

  # Pi-hole Container (Quadlet)
  virtualisation.quadlet.containers.pihole = lib.recursiveUpdate common {
    containerConfig = {
      image = "docker.io/pihole/pihole:latest";
      readOnly = false;

      healthCmd = "dig +short +norecurse +retry=0 -p 53 @${hostIp} pi.hole || exit 1";

      addCapabilities = [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_RAW"
        "CAP_CHOWN"
        "CAP_SETUID"
        "CAP_SETGID"
      ];

      publishPorts = [
        "${hostIp}:53:53/tcp"
        "${hostIp}:53:53/udp"
        "127.0.0.1:5380:80/tcp"
      ];

      environments = {
        FTLCONF_webserver_api_password_file = config.age.secrets.pihole_password.path;

        FTLCONF_dns_listeningMode = "ALL";
        FTLCONF_dns_upstreams = "8.8.8.8;8.8.4.4;1.1.1.1";
        FTLCONF_dns_domain_name = "lan.munkie.dk";
        FTLCONF_dns_revServers = "true,192.168.0.0/24,192.168.0.1,corefw";

        FTLCONF_dns_hosts = ''
          ${hostIp} pi.lan.munkie.dk omada.lan.munkie.dk homeassistant.lan.munkie.dk frigate.lan.munkie.dk id.lan.munkie.dk home.lan.munkie.dk z2m.lan.munkie.dk paperless.lan.munkie.dk beszel.lan.munkie.dk
          192.168.0.200 camera-south.lan.munkie.dk
          192.168.0.201 camera-driveway.lan.munkie.dk
        '';
      };

      volumes = [
        "/persist/services/pihole/config:/etc/pihole:rw,Z,U"
        "${config.age.secrets.pihole_password.path}:${config.age.secrets.pihole_password.path}:ro"
      ];
    };
  };
}
