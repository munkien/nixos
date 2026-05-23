{
  config,
  lib,
  inputs,
  ...
}: {
  # Tailscale configuration
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    authKeyFile = config.age.secrets.tailscale-authkey.path;
    extraUpFlags = ["--ssh" "--accept-dns=true"];
  };

  age.secrets.tailscale-authkey = {
    # Use inputs.self to anchor to the flake root, then provide the absolute path
    rekeyFile = "${inputs.self}/secrets/common/tailscale.age";
    mode = "0400";
  };

  # Network security
  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  # Persistence: Save identity across reboots
  environment.persistence."/persist".directories = lib.mkIf (config.environment.persistence ? "/persist") [
    "/var/lib/tailscale"
  ];
}
