{
  pkgs,
  config,
  lib,
  osConfig,
  inputs,
  ...
}: let
  standardPanel = [
    {
      location = "top";
      height = 30;
      floating = false;
      lengthMode = "fill";
      alignment = "center";
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
      height = 60;
      floating = true;
      lengthMode = "fit";
      alignment = "center";
      hiding = "none";
      widgets = [
        "org.kde.plasma.panelspacer"
        {
          name = "org.kde.plasma.icontasks";
          config.General.launchers = [
            "applications:org.kde.dolphin.desktop"
            "applications:codium.desktop"
            "applications:org.wezfurlong.wezterm.desktop"
            "applications:firefox.desktop"
          ];
        }
        "org.kde.plasma.panelspacer"
      ];
    }
  ];
in {
  # Imports must be inside the main attribute set
  imports = [inputs.plasma-manager.homeModules.plasma-manager];

  config = lib.mkIf osConfig.my.desktop.enable {
    home.packages = with pkgs; [
      wl-clipboard
    ];

    programs.plasma = {
      enable = true;
      overrideConfig = true;

      panels = map (p: p // {screen = "all";}) standardPanel;

      fonts = {
        general = {
          family = "Noto Sans";
          pointSize = 14;
        };
        fixedWidth = {
          family = "FiraCode Nerd Font";
          pointSize = 12;
        };
        small = {
          family = "Noto Sans";
          pointSize = 10;
        };
        toolbar = {
          family = "Noto Sans";
          pointSize = 10;
        };
        menu = {
          family = "Noto Sans";
          pointSize = 10;
        };
        windowTitle = {
          family = "Noto Sans";
          pointSize = 10;
        };
      };

      input.keyboard.layouts = [
        {
          layout = "dk";
          variant = "";
        }
      ];

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
  };
}
