{lib, ...}: {
  # Shared fleet vocabulary: what a host *is*, not how to build one.
  #
  # These options are declared in one module because they are cross-cutting: a
  # single host sets them and NixOS modules, Home Manager modules, the health
  # gate and the assertion suite all read them. They were previously spread over
  # modules/nixos/options.nix and modules/home/options.nix purely by which
  # subsystem consumed them, which meant one host's profile was described in two
  # files that had to agree.
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
        at all (e.g. a kiosk).
      '';
    };

    # User-scoped, but declared here so the whole profile is one surface and the
    # assertion suite can read it without importing the Home Manager module.
    user = {
      developer.enable = lib.mkEnableOption "Enable various developer tools";

      autostart = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Applications to start with the graphical session.";
      };
    };
  };
}
