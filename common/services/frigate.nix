{
  config,
  lib,
  pkgs,
  ...
}: let
  # Settings are declared as attrsets in config.nix and rendered here. Writing
  # frigate's YAML by hand in a Nix string meant a misspelled key was invisible
  # until frigate failed at runtime; as attrsets it is a type error.
  frigateYaml = pkgs.writeText "frigate-config.yml" (lib.generators.toYAML {} config.my.frigateSettings);
in {
  # Settings live in ./frigate/config.nix. Imported here rather than in the host
  # so a host keeps importing a single frigate entrypoint.
  imports = [./frigate/config.nix];

  # The config is bind-mounted from the store rather than copied in by an
  # activation script, which never converges on a running system. Frigate also
  # writes its own state into /config (the database), so that directory stays a
  # real volume.
  # Exposure (vhost + firewall) is declared by the host via my.services.

  age.secrets."frigate" = {
    rekeyFile = ../../secrets/services/frigate.age;
    mode = "0400";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/frigate/shm 1777 root root -"
    "d /var/lib/frigate/config 0755 root root -"
    "d /var/lib/frigate/storage 0755 root root -"
    # Remove the config the retired activation script used to copy here. Left in
    # place it would sit underneath the bind mount and drift silently.
    "r /var/lib/frigate/config/config.yml"
  ];
  systemd.mounts = [
    {
      what = "tmpfs";
      where = "/var/lib/frigate/shm";
      type = "tmpfs";
      options = "size=1G,mode=1777";
    }
  ];

  virtualisation.arion.projects.home-infra.settings.services.frigate.service = {
    image = "ghcr.io/blakeblackshear/frigate:stable";
    privileged = true;
    devices = [
      "/dev/dri/renderD128:/dev/dri/renderD128"
    ];
    volumes = [
      "/var/lib/frigate/config:/config"
      "${frigateYaml}:/config/config.yml:ro"
      "/media/frigate:/media/frigate"
      "/etc/localtime:/etc/localtime:ro"
      "/var/lib/frigate/shm:/dev/shm"
    ];
    env_file = [
      config.age.secrets."frigate".path
    ];
    ports = [
      "8554:8554"
      "5000:5000"
    ];
    networks = ["internal_net"];
    restart = "always";
  };
}
