{
  config,
  pkgs,
  lib,
  ...
}: {
  # ==========================================
  # Podman Base
  # ==========================================
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = false;

    autoPrune = {
      enable = true;
      flags = ["--all"];
      dates = "daily";
    };
  };

  # Requires the Quadlet network to explicitly declare 'networkName = "homelab"'
  networking.firewall.trustedInterfaces = ["homelab"];

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
        interfaceName = "homelab";
        driver = "bridge";
      };
    };
  };
}
