{lib, ...}: {
  options.my.user = {
    developer.enable = lib.mkEnableOption "Enable various developer tools";
    autostart = lib.mkOption {
      type = lib.types.listOf lib.types.str; # Maps "AppName" to "Command"
      default = {};
    };
  };
}
