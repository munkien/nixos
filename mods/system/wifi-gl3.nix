{
  config,
  ...
}: {
  sops.secrets.wifi_password_1 = {};
  sops.secrets.wifi_password_2 = {};
  sops.templates."GL3-5G.nmconnection" = {
    path = "/etc/NetworkManager/system-connections/GL3-5G.nmconnection";
    mode = "0400";
    content = ''
      [connection]
      id=GL3-5G
      type=wifi
      autoconnect=true

      [wifi]
      ssid=sild-paa-daase
      mode=infrastructure

      [wifi-security]
      key-mgmt=wpa-psk
      psk=${config.sops.placeholder.wifi_password_1}

      [ipv4]
      method=auto

      [ipv6]
      method=auto
    '';
  };
  sops.templates."GL3.nmconnection" = {
    path = "/etc/NetworkManager/system-connections/GL3.nmconnection";
    mode = "0600";
    content = ''
      [connection]
      id=GL3
      type=wifi
      autoconnect=false

      [wifi]
      ssid=sild-IoT
      mode=infrastructure

      [wifi-security]
      key-mgmt=wpa-psk
      psk=${config.sops.placeholder.wifi_password_2}

      [ipv4]
      method=auto

      [ipv6]
      method=auto
    '';
  };
}
