{lib, ...}: {
  options.my.user = {
    media.enable = lib.mkEnableOption "Enable various desktop media tools";
  };
}
