{
  config,
  pkgs,
  ...
}: let
  # Define your Frigate YAML configuration here
  frigateYaml = pkgs.writeText "frigate-config.yml" ''
    # Replace this with your actual Frigate configuration
    mqtt:
      host: home-server-1.home.arpa
    cameras: {}
  '';
in {
  # Copies the Nix-defined config to a mutable path on every rebuild
  system.activationScripts.frigateConfig = ''
    mkdir -p /var/lib/frigate/config
    cp -f ${frigateYaml} /var/lib/frigate/config/config.yml
    chmod 0644 /var/lib/frigate/config/config.yml
  '';

  networking.firewall.allowedTCPPorts = [5000];
  networking.firewall.allowedUDPPorts = [5000 8554];

  virtualisation.arion.projects.home-infra.settings.services.frigate.service = {
    image = "ghcr.io/blakeblackshear/frigate:stable";
    privileged = true;
    volumes = [
      # Mount the mutable file without the :ro flag
      "/var/lib/frigate/config/config.yml:/config/config.yml"
      "/var/lib/frigate/storage:/media/frigate"
      "/etc/localtime:/etc/localtime:ro"
    ];
    ports = [
      "8554:8554"
      "5000:5000"
    ];
    networks = ["internal_net"];
    restart = "always";
  };

  services.caddy.virtualHosts."frigate.munkie.dk" = {
    extraConfig = ''
      reverse_proxy 127.0.0.1:5000
    '';
  };
}
