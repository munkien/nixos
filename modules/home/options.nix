{
  lib,
  config,
  osConfig,
  ...
}: {
  options.my.user = {
    media.enable = lib.mkEnableOption "Enable various desktop media tools";
    developer.enable = lib.mkEnableOption "Enable various developer tools";
    autostart = lib.mkOption {
      type = lib.types.listOf lib.types.str; # Maps "AppName" to "Command"
      default = {};
    };
  };
}
