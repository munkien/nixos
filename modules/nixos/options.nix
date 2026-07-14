{lib, ...}: {
  options.my = {
    desktop.enable = lib.mkEnableOption "Whether this system is a desktop/graphical interface or not. Affects various desktop-related configurations.";
    server.enable = lib.mkEnableOption "Whether this system is a server or not. Affects various server-related configurations.";
    gaming.enable = lib.mkEnableOption "Whether this system is used for gaming. Affects various gaming-related configurations.";
  };
}
