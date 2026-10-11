{
  pkgs,
  config,
  lib,
  osConfig,
  ...
}:
lib.mkIf osConfig.my.desktop.enable {
  home.packages = with pkgs; [
    pywalfox-native
  ];

  programs.firefox = {
    enable = lib.mkDefault true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    policies = {
      DisplayBookmarksToolbar = "always";
      DisableMasterPasswordCreation = true;
      PasswordManagerEnabled = false;
      SkipTermsOfUse = true;
      ShowHomeButton = true;
      DisableProfileImport = true;
      DisableTelemetry = true;
      DefaultDownloadDirectory = "/scratch/download";

      ExtensionSettings = {
        "plasma-browser-integration@kde.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
          installation_mode = "force_installed";
        };

        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };

        "dearrow@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/dearrow/latest.xpi";
          installation_mode = "force_installed";
        };

        "78272b6fa58f4a1abaac99321d503a20@proton.me" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
          installation_mode = "force_installed";
        };

        "vpn@proton.ch" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-vpn-firefox-extension/latest.xpi";
          installation_mode = "force_installed";
        };

        "steamdb" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4891926/steam_database-4.35.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];

    profiles = {
      Home = {
        id = 0;
        name = "Home";
        path = "munkien";
        isDefault = true;

        settings = {
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };

        search = {
          force = true;
          default = "ddg";

          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages?query={searchTerms}";
                }
              ];
              icon = "https://nixos.org/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = ["@np"];
            };

            "GitHub" = {
              urls = [
                {
                  template = "https://github.com/search?q={searchTerms}&type=repositories";
                }
              ];
              definedAliases = ["@gh"];
            };

            "google".metaData.hidden = true;
          };
        };

        bookmarks = {
          force = true;

          settings = [
            {
              name = "AI";
              toolbar = true;
              bookmarks = [
                {
                  name = "Gemini";
                  url = "https://gemini.google.com";
                }
                {
                  name = "ChatGPT";
                  url = "https://chatgpt.com";
                }
              ];
            }

            {
              name = "Economy";
              toolbar = true;
              bookmarks = [
                {
                  name = "Actual Budget";
                  url = "https://vehement-jaguar.pikapod.net/budget";
                }
              ];
            }

            {
              name = "Gaming";
              toolbar = true;
              bookmarks = [
                {
                  name = "Stardew Valley Expanded Wiki";
                  url = "https://stardewvalleyexpanded.wiki.gg/";
                  tags = ["gaming" "wiki"];
                }
              ];
            }

            {
              name = "Entertainment";
              toolbar = true;
              bookmarks = [
                {
                  name = "YouTube";
                  url = "https://youtube.com/";
                  tags = ["entertainment"];
                }
                {
                  name = "HBO";
                  url = "https://hbomax.com/";
                  tags = ["entertainment"];
                }
                {
                  name = "NetFlix";
                  url = "https://netflix.com/";
                  tags = ["entertainment"];
                }
              ];
            }

            {
              name = "Development";
              toolbar = true;
              bookmarks = [
                {
                  name = "NixOS Search";
                  url = "https://search.nixos.org/packages";
                  tags = ["nix" "dev"];
                }
                {
                  name = "NixOS Plasma Manager Search";
                  url = "https://nix-community.github.io/plasma-manager/options.xhtml";
                  tags = ["nix" "dev"];
                }
                {
                  name = "NixOS Home Manager Search";
                  url = "https://home-manager-options.extranix.com/";
                  tags = ["nix" "dev"];
                }
                {
                  name = "NixOS Noogle Search";
                  url = "https://noogle.dev/";
                  tags = ["nix" "dev"];
                }
              ];
            }
          ];
        };
      };

      Work = {
        id = 1;
        name = "Work";
        path = "work";

        settings = {
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };

      Midtfyns = {
        id = 2;
        name = "Midtfyns";
        path = "midtfyns";

        settings = {
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };

      H = {
        id = 3;
        name = "H";
        path = "h";

        settings = {
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };
      };
    };
  };

  xdg.desktopEntries = {
    firefox-home = {
      name = "Firefox — Home";
      genericName = "Personal Browser";
      exec = "firefox -P Home -no-remote %U";
      icon = "firefox";
      terminal = false;
      categories = ["Network" "WebBrowser"];
    };

    firefox-work = {
      name = "Firefox — Work";
      genericName = "Work Browser";
      exec = "firefox -P Work -no-remote %U";
      icon = "firefox";
      terminal = false;
      categories = ["Network" "WebBrowser"];
    };

    firefox-midtfyns = {
      name = "Firefox — Midtfyns";
      genericName = "Midtfyns Browser";
      exec = "firefox -P Midtfyns -no-remote %U";
      icon = "firefox";
      terminal = false;
      categories = ["Network" "WebBrowser"];
    };

    firefox-h = {
      name = "Firefox — H";
      genericName = "H Browser";
      exec = "firefox -P H -no-remote %U";
      icon = "firefox";
      terminal = false;
      categories = ["Network" "WebBrowser"];
    };
  };
}
