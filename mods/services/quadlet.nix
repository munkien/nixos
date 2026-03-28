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

  # Containers user for rootless podman
  users.groups.containers = {};

  users.users.containers = {
    isSystemUser = true;
    home = "/persist/var/lib/containers-user";
    createHome = true;
    description = "Service account for rootless containers";
    group = "containers";
    # 100 containers * 65536 IDs = 6553600 total IDs
    subUidRanges = [
      {
        startUid = 100000;
        count = 6553600;
      }
    ];

    subGidRanges = [
      {
        startGid = 100000;
        count = 6553600;
      }
    ];
  };

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
