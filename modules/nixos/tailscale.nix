{
  config,
  inputs,
  lib,
  ...
}: {
  # Tailscale configuration
  services.tailscale = {
    enable = lib.mkDefault true;
    useRoutingFeatures = "client";
    authKeyFile = config.age.secrets.tailscale-authkey.path;
    extraUpFlags = ["--ssh" "--accept-dns=true"];
    authKeyParameters.ephemeral = true;
  };

  age.secrets.tailscale-authkey = {
    rekeyFile = "${inputs.self}/secrets/common/tailscale.age";
    mode = "0400";
  };

  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  preservation.preserveAt."/persist" = {
    directories = [
      "/var/lib/tailscale"
    ];
  };
}
