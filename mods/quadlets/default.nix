{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable podman
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
      dates = "daily";
    };
    defaultNetwork.settings.dns_enabled = false;
  };

  networking.firewall.trustedInterfaces = [ "homelab" ];

  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) networks pods;
    in
    {
      enable = true;
      autoEscape = true;
      autoUpdate = {
        enable = true;
        calendar = "daily";
      };

      networks.homelab = {
        networkConfig = {
          name = "homelab";
          driver = "bridge";
        };
        serviceConfig.RemainAfterExit = true;
      };
    };

}

