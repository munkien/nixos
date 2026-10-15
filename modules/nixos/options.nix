{lib, ...}: {
  options.my = {
    desktop.enable = lib.mkEnableOption "Whether this system is a desktop/graphical interface or not. Affects various desktop-related configurations.";
    gaming.enable = lib.mkEnableOption "Whether this system is used for gaming. Affects various gaming-related configurations.";

    containers.user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "munkien";
      description = ''
        User to add to the "podman" and "docker" groups so they can manage
        containers. Defaults to null because a host may have no interactive user
        at all (e.g. a kiosk). Declared here rather than in the arion service
        module so it exists on every host, including those that do not import
        arion.
      '';
    };
  };
}
