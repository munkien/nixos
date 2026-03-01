{config, ...}: {
  sops.secrets.wifi_password_1 = {};
  sops.secrets.wifi_password_2 = {};

  sops.templates."wifi-secrets.env".content = ''
    WIFI_PASS_1="${config.sops.placeholder.wifi_password_1}"
    WIFI_PASS_2="${config.sops.placeholder.wifi_password_2}"
  '';

  systemd.services.NetworkManager-ensure-profiles = {
    # This runs immediately before your declarative profiles are written
    preStart = "rm -f /etc/NetworkManager/system-connections/*.nmconnection";
  };

  networking.networkmanager = {
    enable = true;

    ensureProfiles = {
      environmentFiles = [config.sops.templates."wifi-secrets.env".path];

      profiles = {
        "GL3-5G" = {
          connection = {
            id = "GL3-5G";
            type = "wifi";
            autoconnect = true;
          };
          wifi = {
            ssid = "sild-paa-daase";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$WIFI_PASS_1";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };

        "GL3" = {
          connection = {
            id = "GL3";
            type = "wifi";
            autoconnect = false;
          };
          wifi = {
            ssid = "sild-IoT";
            mode = "infrastructure";
          };
          wifi-security = {
            key-mgmt = "wpa-psk";
            psk = "$WIFI_PASS_2";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };
  };
}
