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

        {
          name = "org.kde.plasma.systemtray";
          config = {
            General = {
              hiddenItems = [
                "org.kde.plasma.battery"
                "org.kde.plasma.brightness"
              ];

              shownItems = [
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
                "org.kde.plasma.clipboard"
              ];
            };
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
    wl-clipboard
    kdePackages.plasma-browser-integration
  ];

  xdg.dataFile."color-schemes/TokyoNight.colors".source = "${pkgs.tokyonight-gtk-theme}/share/themes/Tokyonight-Dark/kde/TokyoNight.colors";

  programs.plasma = {
    enable = true;
    overrideConfig = true;

    input.keyboard.numlockOnStartup = "on";

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

      "ksmserverrc"."General" = {
        "loginMode" = "emptySession"; # You already have this
        "confirmLogout" = false; # <--- ADDS INSTANT SHUTDOWN
        "offerShutdown" = true; # Ensures the option is still available
      };

      # Theming / Kwin
      "kdeglobals"."KDE"."widgetStyle" = "kvantum";
      "kwinrc"."Plugins" = {
        "blurRadius" = 12;
        "translucencyOpaque" = 85;
        "magiclampEnabled" = true;
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

  systemd.user.services = {
    # 30 Second Delay
    steam = {
      Unit = {
        Description = "Steam";
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 30";
        ExecStart = "${pkgs.steam}/bin/steam -silent";
        Restart = "on-failure";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };

    # 80 Second Delay
    spotify = {
      Unit = {
        Description = "Spotify";
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 80";
        ExecStart = "${pkgs.spotify}/bin/spotify";
        Restart = "on-failure";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };

    # 120 Second Delay
    discord = {
      Unit = {
        Description = "Discord";
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 120";
        ExecStart = "${pkgs.discord}/bin/discord";
        Restart = "on-failure";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };
  };
}
