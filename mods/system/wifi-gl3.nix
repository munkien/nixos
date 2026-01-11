{
  lib,
  pkgs,
  ...
}: {
  sops.secrets.wifi_password = {};
  sops.templates."GL3-5G.nmconnection" = {
    path = "/etc/NetworkManager/system-connections/GL3-5G.nmconnection";
    mode = "0600";
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
      psk=${config.sops.secrets.wifi_password.placeholder}

      [ipv4]
      method=auto

      [ipv6]
      method=auto
    '';
  };
}
