# modules/common/wifi-gl3.nix
{config, ...}: {
  age.secrets.wifi-gl3 = {
    rekeyFile = ../../secrets/common/wifi-gl3_env.age;
    owner = "root";
    mode = "0600";
  };

  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [config.age.secrets.wifi-gl3.path];
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
            psk = "$WIFI_PASS_5";
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
            psk = "$WIFI_PASS_24";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };
  };
}
