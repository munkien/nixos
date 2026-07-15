{
  lib,
  config,
  osConfig,
  ...
}:
lib.mkIf osConfig.my.desktop.enable {
  # This automatically turns the attribute set into .desktop files
  xdg.configFile = lib.listToAttrs (map (name: {
      name = "autostart/${name}.desktop";
      value = {
        text = ''
          [Desktop Entry]
          Type=Application
          Exec=${name}
          Name=${name}
          X-GNOME-Autostart-enabled=true
        '';
      };
    })
    config.my.user.autostart);
}
