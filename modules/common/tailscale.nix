# modules/common/tailscale.nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    authKeyFile = config.age.secrets.tailscale-authkey.path;
    extraUpFlags = [
      "--ssh"
      "--accept-dns=true"
    ];
  };

  # Tailscale secret — add the corresponding .age file to your secrets
  age.secrets.tailscale-authkey = {
    rekeyFile = ../../secrets/tailscale-authkey.age;
    mode = "0400";
  };

  # Open firewall for Tailscale
  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };

  # Persist Tailscale state so the machine keeps its identity across reboots
  environment.persistence."/persist".directories =
    lib.mkIf
    (config.environment.persistence ? "/persist")
    ["/var/lib/tailscale"];

  # Ensure Tailscale is up before SSH
  systemd.services.tailscale-autoconnect = {
    description = "Automatic Tailscale connection";
    after = ["network-pre.target" "tailscale.service"];
    wants = ["network-pre.target" "tailscale.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      # Wait for tailscaled to be ready
      sleep 2
      status="$(${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq -r .BackendState)"
      if [ "$status" = "Running" ]; then
        echo "Already connected"
        exit 0
      fi
      ${pkgs.tailscale}/bin/tailscale up
    '';
  };
}
