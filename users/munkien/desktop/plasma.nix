{
  pkgs,
  config,
  lib,
  ...
}: let
  # Centralize theme definitions for consistency
  themeConfig = {
    gtkThemeName = "Tokyonight-Dark"; # Adjust if the specific package variant differs
    iconName = "Papirus-Dark";
    cursorName = "Bibata-Modern-Ice";
    fontName = "JetBrainsMono Nerd Font";
  };

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
        "org.kde.plasma.systemtray"
        "org.kde.plasma.digitalclock"
        "org.kde.plasma.showdesktop"
      ];
    }
    {
      location = "bottom";
      height = 40;
      floating = true;
      widgets = [
        "org.kde.plasma.panelspacer"
        {
          name = "org.kde.plasma.taskmanager";
          config.General.launchers = [
            "applications:org.kde.dolphin.desktop"
            "applications:code.desktop"
            "applications:kitty.desktop"
            "applications:firefox.desktop"
          ];
        }
        "org.kde.plasma.panelspacer"
      ];
    }
  ];

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
    wl-clipboard
    kdePackages.plasma-browser-integration
  ];

  # --- NEW: GTK Configuration ---
  # This forces GTK apps (Firefox) to use the themes installed, matching KDE
  gtk = {
    enable = true;
    theme = {
      name = themeConfig.gtkThemeName;
      package = pkgs.tokyonight-gtk-theme;
    };
    iconTheme = {
      name = themeConfig.iconName;
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = themeConfig.cursorName;
      package = pkgs.bibata-cursors;
    };
    font = {
      name = themeConfig.fontName;
      size = 11;
    };
  };

  programs.plasma = {
    enable = true;
    overrideConfig = true;

    panels = lib.flatten [
      (map (p: p // {screen = 0;}) standardPanel)
      (map (p: p // {screen = 1;}) standardPanel)
    ];

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      splashScreen.theme = "Breeze Dark";
      iconTheme = themeConfig.iconName;
      cursor.theme = themeConfig.cursorName;
      wallpaper = "${./default-wallpaper.jpg}";
    };

    fonts = {
      general = {
        family = themeConfig.fontName;
        pointSize = 14;
      };
      fixedWidth = {
        family = themeConfig.fontName;
        pointSize = 12;
      };
      small = {
        family = themeConfig.fontName;
        pointSize = 10;
      };
    };

    kwin = {
      effects = {
        blur = {
          enable = true;
          strength = 12;
        };
        translucency.enable = true;
      };
      titlebarButtons = {
        left = ["maximize" "minimize"];
        right = ["close"];
      };
    };

    configFile = {
      "kdeglobals"."KDE"."widgetStyle" = "Breeze";

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

      "baloofilerc"."General" = {
        "exclude folders" = "${config.home.homeDirectory}/.cache/,${config.home.homeDirectory}/.nix-profile/,${config.home.homeDirectory}/.local/state/,${config.home.homeDirectory}/.cargo/";
        "exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.nix,node_modules,build,target";
        "exclude filters version" = 9;
      };
    };

    shortcuts = {
      "klipper"."Show Clipboard at Mouse Position" = "Meta+V";
      "spectacle" = {
        "Launch" = "Meta+Print";
        "FullScreenScreenShot" = "Print";
        "RectangularRegionScreenShot" = "Meta+Shift+S";
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.kdePackages.xdg-desktop-portal-kde];
    config.common.default = "kde";
  };

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
  xdg.configFile."mimeapps.list".force = true;

  systemd.user.services = {
    steam = mkDelayedStart "Steam" 5 "${pkgs.steam}/bin/steam -silent";
    spotify = mkDelayedStart "Spotify" 10 "${pkgs.spotify}/bin/spotify";
    discord = mkDelayedStart "Discord" 15 "${pkgs.discord}/bin/discord";
    heroic = mkDelayedStart "Heroic" 15 "${pkgs.heroic}/bin/heroic";

    clear-plasma-cache = {
      Unit = {
        Description = "Clean Plasma metadata cache on startup";
        Before = ["plasma-plasmashell.service"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'rm -rf %h/.cache/plasmashell* %h/.cache/ksycoca6* %h/.cache/org.kde.dirmodel-cache.kcache'";
        RemainAfterExit = false;
      };
      Install = {WantedBy = ["plasma-workspace.target"];};
    };
  };
}
