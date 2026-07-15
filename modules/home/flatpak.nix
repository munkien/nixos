{
  inputs,
  config,
  lib,
  osConfig,
  ...
}: {
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  config = lib.mkIf osConfig.my.desktop.enable {
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
  };
}
