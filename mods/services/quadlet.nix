{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ==========================================
  # Podman Base
  # ==========================================
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = false;
    
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
      dates = "daily";
    };
  };

  # Trust the Quadlet bridge network for cross-container & host communication
  networking.firewall.trustedInterfaces = [ "homelab" ];

  # ==========================================
  # Quadlet Global Settings
  # ==========================================
  virtualisation.quadlet = {
    enable = true;
    autoEscape = true;
    
    autoUpdate = {
      enable = true;
      calendar = "daily";
    };

    # The baseline bridge network for all homelab containers
    networks.homelab = {
      networkConfig = {
        name = "homelab";
        driver = "bridge";
      };
      serviceConfig.RemainAfterExit = true;
    };
  };
}
