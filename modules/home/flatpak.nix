{
  lib,
  osConfig,
  ...
}:
lib.mkIf osConfig.my.desktop.enable {
  services.flatpak = {
    enable = true;
    uninstallUnused = true;

    update = {
      onActivation = true;

      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };
  };
}
