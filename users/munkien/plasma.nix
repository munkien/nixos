{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  # Define panels layout
  panelsDefinition = [
    {
      location = "top";
      height = 30;
      floating = false;
      lengthMode = "fill";
      hiding = "none";

      widgets = [
        "org.kde.plasma.kickoff"
        "org.kde.plasma.appmenu"
        "org.kde.plasma.panelspacer"
        "org.kde.plasma.systemtray"
        "org.kde.plasma.digitalclock"
        "org.kde.plasma.showdesktop"
      ];
    }
    {
      location = "bottom";
      height = 52;
      floating = false;
      widgets = [
        "org.kde.plasma.panelspacer"
        {
          name = "org.kde.plasma.icontasks";
          config.General.launchers = [
            "applications:codium.desktop"
            "applications:kitty.desktop"
            "applications:firefox.desktop"
          ];
        }
        "org.kde.plasma.panelspacer"
      ];
    }
  ];
in {
  home.packages = with pkgs; [
    sweet-nova
    candy-icons
    kdePackages.qtstyleplugin-kvantum
    tokyonight-gtk-theme
    nerd-fonts.jetbrains-mono
    pkgs.wl-clipboard
  ];

  xdg.dataFile."color-schemes/TokyoNight.colors".source = "${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark/kde/TokyoNight.colors";

  programs.plasma = {
    enable = true;
    overrideConfig = true;

    panels = lib.flatten [
      (map (p: p // {screen = 0;}) panelsDefinition)
      (map (p: p // {screen = 1;}) panelsDefinition)
    ];

    configFile = {
      # Clipboard / Spectacle
      "klipperrc"."General" = {
        "MaxClipItems" = 100;
        "KeepClipboardContents" = true;
        "IgnoreImages" = false;
        "SyncClipboards" = false;
      };

      "spectaclerc" = {
        "General" = {
          "autoSaveImage" = true;
          "clipboardGroup" = "PostScreenshotCopyImage";
          "launchAction" = "UseLastUsedCaptureMode";
        };
        "Gui" = {
          "quitAfterSaveCopyExport" = true;
        };
        "ImageSave" = {
          "imageFilenamePattern" = "Screenshot_%Y-%M-%D_%H-%m.png";
          "preferredImageFormat" = "Png";
        };
      };

      "ksmserverrc"."General"."loginMode" = "emptySession";

      # Theming / Kwin
      "kdeglobals"."KDE"."widgetStyle" = "kvantum";
      "kwinrc"."Plugins" = {
        "blurRadius" = 12;
        "translucencyOpaque" = 85;
        "magiclampEnabled" = true;
      };

      "plasmarc"."Theme"."name" = "breeze-dark";
      "ksplashrc"."KSplash"."Theme" = "None";

      "kde-gtk-configrc"."General" = {
        "gtkTheme" = "Sweet-Dark";
        "iconTheme" = "candy-icons";
        "font" = "JetBrainsMono Nerd Font,12,-1,5,50,0,0,0,0,0";
      };
    };

    shortcuts = {
      "klipper"."Show Clipboard at Mouse Position" = "Meta+V";
      "spectacle" = {
        "Launch" = "Meta+Print";
        "FullScreenScreenShot" = "Print";
        "ActiveWindowScreenShot" = "Meta+Print";
        "RectangularRegionScreenShot" = "Meta+Shift+S";
      };
    };

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "candy-icons";
      cursor.theme = "Sweet-cursors";
      colorScheme = "TokyoNight";
      wallpaper = ./default-wallpaper.jpg;
    };

    fonts = {
      general = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 14;
      };
      fixedWidth = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 12;
      };
      small = {
        family = "JetBrainsMono Nerd Font";
        pointSize = 10;
      };
    };

    kwin.effects = {
      blur.enable = true;
      translucency.enable = true;
    };
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = "theme=Sweet";
  home.sessionVariables.GTK_THEME = "Sweet-Dark";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };

  home.file.".config/autostart/steam.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Steam
    Exec=steam -silent
  '';
  home.file.".config/autostart/spotify.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Spotify
    Exec=spotify --minimized
  '';
  home.file.".config/autostart/discord.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Discord
    Exec=discord --start-minimized
  '';
}
