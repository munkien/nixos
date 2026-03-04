{
  config,
  inputs,
  ...
}: {
  imports = [inputs.agenix.nixosModules.default];

  age.secrets."secrets_wifi_env".file = ../../secrets/secret_wifi_env.age;

  networking.networkmanager = {
    enable = true;

    ensureProfiles = {
      environmentFiles = [config.age.secrets."secrets_wifi_env".path];

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
