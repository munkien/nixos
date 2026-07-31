{
  config,
  pkgs,
  ...
}: {
  services.glances = {
    enable = true;
    openFirewall = true;
  };
}
