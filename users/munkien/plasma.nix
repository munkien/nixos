{
  pkgs,
  lib,
  ...
}: let
  standardPanel = [
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
        {
          name = "org.kde.plasma.systemtray";
          config.General = {
            hiddenItems = ["org.kde.plasma.battery" "org.kde.plasma.brightness"];
            shownItems = ["org.kde.plasma.networkmanagement" "org.kde.plasma.volume" "org.kde.plasma.clipboard"];
          };
        }
        "org.kde.plasma.digitalclock"
        "org.kde.plasma.showdesktop"
      ];
    }
    {
      location = "bottom";
      height = 60;
      floating = false;
      widgets = [
        "org.kde.plasma.panelspacer"
        {
          name = "org.kde.plasma.icontasks";
          config.General.launchers = [
            "applications:org.kde.dolphin.desktop"
            "applications:codium.desktop"
            "applications:kitty.desktop"
            "applications:firefox.desktop"
          ];
        }
        "org.kde.plasma.panelspacer"
      ];
    }
  ];

  # Helper to create delayed startup services (Reduces boilerplate)
  mkDelayedStart = name: delay: exec: {
    Unit = {
      Description = "${name} Autostart";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep ${toString delay}";
      ExecStart = "${exec}";
      Restart = "on-failure";
    };
    Install = {WantedBy = ["graphical-session.target"];};
  };
in {
  home.packages = with pkgs; [
    # Theming
    tokyonight-gtk-theme
    papirus-icon-theme # Clean, flat icons that fit Tokyo Night better than Candy
    bibata-cursors # Modern, clean cursor

    # Fonts
    nerd-fonts.jetbrains-mono

    # Tools
    wl-clipboard
    kdePackages.plasma-browser-integration
  ];

  # 1. Extract the Color Scheme from the GTK package
  # This makes the "TokyoNight" scheme available to Plasma
  xdg.dataFile."color-schemes/TokyoNight.colors".source = "${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark/kde/TokyoNight.colors";

  programs.plasma = {
    enable = true;
    overrideConfig = true;

    # 2. Panels (Applied to Screen 0 and 1)
    panels = lib.flatten [
      (map (p: p // {screen = 0;}) standardPanel)
      (map (p: p // {screen = 1;}) standardPanel)
    ];

    # 3. Workspace Appearance
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop"; # Use standard Breeze as base
      colorScheme = "TokyoNight"; # Apply our extracted colors
      iconTheme = "Papirus-Dark"; # Matches dark themes perfectly
      cursor.theme = "Bibata-Modern-Ice"; # Matches the Tokyo Night blue/white text
      wallpaper = ./default-wallpaper.jpg;
    };

    # 4. Fonts
    fonts = let
      fontName = "JetBrainsMono Nerd Font";
    in {
      general = {
        family = fontName;
        pointSize = 14;
      };
      fixedWidth = {
        family = fontName;
        pointSize = 12;
      };
      small = {
        family = fontName;
        pointSize = 10;
      };
    };

    # 5. Window Management (KWin)
    kwin = {
      effects = {
        blur.enable = true;
        translucency.enable = true;
      };
      titlebarButtons = {
        left = ["maximize" "minimize"];
        right = ["close"];
      };
    };

    # 6. Detailed Configuration (RC Files)
    configFile = {
      "kdeglobals"."KDE"."widgetStyle" = "Breeze";

      "kwinrc"."Plugins" = {
        "blurRadius" = 12;
        "translucencyOpaque" = 85; # 85% Opacity
      };

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
        "Gui"."quitAfterSaveCopyExport" = true;
        "ImageSave" = {
          "imageFilenamePattern" = "Screenshot_%Y-%M-%D_%H-%m.png";
          "preferredImageFormat" = "Png";
        };
      };

      "ksmserverrc"."General" = {
        "loginMode" = "emptySession";
        "confirmLogout" = false;
        "offerShutdown" = true;
      };
    };

    # 7. Shortcuts
    shortcuts = {
      "klipper"."Show Clipboard at Mouse Position" = "Meta+V";
      "spectacle" = {
        "Launch" = "Meta+Print";
        "FullScreenScreenShot" = "Print";
        "RectangularRegionScreenShot" = "Meta+Shift+S";
      };
    };
  };

  # Set Default Apps
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

  # Delayed Startup Services
  systemd.user.services = {
    steam = mkDelayedStart "Steam" 30 "${pkgs.steam}/bin/steam -silent";
    spotify = mkDelayedStart "Spotify" 80 "${pkgs.spotify}/bin/spotify";
    discord = mkDelayedStart "Discord" 120 "${pkgs.discord}/bin/discord";
  };
}
