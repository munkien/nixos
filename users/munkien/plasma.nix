{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  # Define the script first
  bcachefsStatus = pkgs.writeShellScript "bcachefs-status.sh" ''
    # Sti til dit specifikke filesystem
    SYS_PATH="/sys/fs/bcachefs/fe8de683-7e92-4cc0-ace2-8ce2bccfa296"

    if [ ! -d "$SYS_PATH" ]; then
      echo "BFS: NOT FOUND"
      exit 1
    fi

    # Note: Ensure your user has read permissions for this file, or use sudo wrapper
    USAGE=$(cat "$SYS_PATH/internal/usage_stats")

    # State check
    STATE=$(${pkgs.bcachefs-tools}/bin/bcachefs list_volumes / | grep -q "failed\|ro" && echo "!!DEGRADED!!" || echo "OK")

    # Pending Reconcile parsing
    PENDING_RAW=$(echo "$USAGE" | grep "reconcile:" | awk '{print $2}')

    # Warning logic
    WARN=""
    if [[ "$PENDING_RAW" =~ [GT] ]]; then
        WARN="⚠️ "
    fi

    USED=$(echo "$USAGE" | grep "data:" | awk '{print $2}')

    echo "BFS: $STATE | $USED | ''${WARN}Pnd: $PENDING_RAW"
  '';

  # Define panels layout
  panelsDefinition = [
    {
      location = "top";
      height = 40;
      widgets = [
        "org.kde.plasma.lock_logout"
        "org.kde.plasma.panelspacer"
        "org.kde.plasma.mediacontroller"
        "org.kde.plasma.panelspacer"
        {
          name = "org.kde.plasma.commandoutput"; # Ensure this widget is installed (plasma-applet-commandoutput)
          config = {
            General = {
              command = "${bcachefsStatus}";
              interval = 60;
              showTitle = false;
              displayType = "text";
            };
          };
        }
        "org.kde.plasma.panelspacer"
        "org.kde.plasma.digitalclock"
      ];
    }
    {
      location = "bottom";
      height = 44;
      widgets = [
        "org.kde.plasma.kickoff"
        "org.kde.plasma.panelspacer"
        {
          name = "org.kde.plasma.icontasks";
          config.General.launchers = [
            "applications:codium.desktop"
            "applications:kitty.desktop"
            "applications:firefox.desktop"
            "applications:systemsettings.desktop"
          ];
        }
        "org.kde.plasma.panelspacer"
        {
          name = "org.kde.plasma.systemmonitor";
          config = {
            Appearance.chartType = "textOnly";
            Sensors.sensors = ["cpu/all/usage" "mem/physical/usedpercent"];
          };
        }
        "org.kde.plasma.systemtray"
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

    # MERGED CONFIG BLOCK (Fixes the duplicate key error)
    configFile = {
      # Clipboard / Spectacle
      "klipperrc"."General" = {
        "MaxClipItems" = 100;
        "KeepClipboardContents" = true;
        "IgnoreImages" = false;
        "SyncClipboards" = true;
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

      # Theming / Kwin
      "kdeglobals"."KDE"."widgetStyle" = "kvantum";
      "kwinrc"."Plugins" = {
        "blurRadius" = 12;
        "translucencyOpaque" = 85;
        "magiclampEnabled" = true;
      };

      # Force Taskbar/Panel to be Dark (matches Tokyo Night better)
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
}
