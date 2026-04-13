{
  config,
  lib,
  ...
}: {
  options.my.containers.enable = lib.mkEnableOption "Podman and Quadlet container runtime";

  config = lib.mkIf config.my.containers.enable {
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
    networking.firewall.trustedInterfaces = ["homelab"];
    users.groups.containers = {};
    users.users.containers = {
      isSystemUser = true;
      home = "/persist/var/lib/containers-user";
      createHome = true;
      description = "Service account for rootless containers";
      group = "containers";
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
    virtualisation.quadlet = {
      enable = true;
      autoEscape = true;
      autoUpdate = {
        enable = true;
        calendar = "daily";
      };
      networks.homelab = {
        networkConfig = {
          interfaceName = "homelab";
          driver = "bridge";
        };
      };
    };
  };
}
