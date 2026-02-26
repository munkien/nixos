{config, ...}: {
  # Ensure NetworkManager waits for sops to decrypt and render templates
  systemd.services.NetworkManager = {
    wants = ["sops-nix.service"];
    after = ["sops-nix.service"];
  };

  sops.secrets.wifi_password_1 = {};
  sops.secrets.wifi_password_2 = {};

  # Shared configuration for templates
  sops.templates."GL3-5G.nmconnection" = {
    path = "/etc/NetworkManager/system-connections/GL3-5G.nmconnection";
    mode = "0600"; # Corrected mode
    owner = "root";
    group = "root";
    content = ''
      [connection]
      id=GL3-5G
      uuid=e82f768b-5a12-4d2a-9b1a-8c1d5a7b6c1d
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
    owner = "root";
    group = "root";
    content = ''
      [connection]
      id=GL3
      uuid=a31d876c-2b11-4e3a-8c2b-9d2e6f8a7b2e
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
