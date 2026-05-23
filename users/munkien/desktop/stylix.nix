{pkgs, ...}: {
  stylix = {
    enable = true;
    image = ./default-wallpaper.jpg;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    polarity = "dark";

    opacity = {
      applications = 0.95;
      terminal = 0.85;
      popups = 0.90;
      desktop = 1.0;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sizes = {
        desktop = 11;
        popups = 11;
      };
    };
  };

  stylix.targets.kde.enable = false;
  stylix.targets.qt.enable = false;
}
