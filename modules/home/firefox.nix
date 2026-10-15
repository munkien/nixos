{
  pkgs,
  config,
  lib,
  osConfig,
  ...
}: let
  # Force-install an extension from AMO by its slug.
  amo = slug: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    installation_mode = "force_installed";
  };

  # Prefs shared by every profile.
  commonSettings = {
    "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
    "widget.use-xdg-desktop-portal.file-picker" = 1;
  };

  # Bookmark helper: bm "Name" "https://..." [ "tag" ]
  bm = name: url: tags: {inherit name url tags;};

  # Desktop launcher for a given profile name.
  mkLauncher = profile: genericName: {
    name = "Firefox — ${profile}";
    inherit genericName;
    exec = ''firefox -P "${profile}" -no-remote %U'';
    icon = "firefox";
    terminal = false;
    categories = ["Network" "WebBrowser"];
  };
in
  lib.mkIf osConfig.my.desktop.enable {
    home.packages = [pkgs.pywalfox-native];

    programs.firefox = {
      enable = lib.mkDefault true;
      configPath = "${config.xdg.configHome}/mozilla/firefox";

      nativeMessagingHosts = [pkgs.kdePackages.plasma-browser-integration];

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
          "plasma-browser-integration@kde.org" = amo "plasma-integration";
          "sponsorBlocker@ajay.app" = amo "sponsorblock";
          "dearrow@ajay.app" = amo "dearrow";
          "78272b6fa58f4a1abaac99321d503a20@proton.me" = amo "proton-pass";
          "vpn@proton.ch" = amo "proton-vpn-firefox-extension";
          "firefox-extension@steamdb.info" = amo "steam-database";
        };
      };

      profiles = {
        Home = {
          id = 0;
          name = "Home";
          path = "munkien";
          isDefault = true;
          settings = commonSettings;

          search = {
            force = true;
            default = "ddg";

            engines = {
              "Nix Packages" = {
                urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
                icon = "https://nixos.org/favicon.png";
                updateInterval = 24 * 60 * 60 * 1000;
                definedAliases = ["@np"];
              };

              "GitHub" = {
                urls = [{template = "https://github.com/search?q={searchTerms}&type=repositories";}];
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
                  (bm "Gemini" "https://gemini.google.com/" [])
                  (bm "ChatGPT" "https://chatgpt.com/" [])
                ];
              }
              {
                name = "Economy";
                toolbar = true;
                bookmarks = [
                  (bm "Actual Budget" "https://vehement-jaguar.pikapod.net/budget" [])
                ];
              }
              {
                name = "Gaming";
                toolbar = true;
                bookmarks = [
                  (bm "Stardew Valley Expanded Wiki" "https://stardewvalleyexpanded.wiki.gg/" ["gaming" "wiki"])
                ];
              }
              {
                name = "Entertainment";
                toolbar = true;
                bookmarks = [
                  (bm "YouTube" "https://youtube.com/" ["entertainment"])
                  (bm "HBO" "https://hbomax.com/" ["entertainment"])
                  (bm "Netflix" "https://netflix.com/" ["entertainment"])
                ];
              }
              {
                name = "Development";
                toolbar = true;
                bookmarks = [
                  (bm "NixOS Search" "https://search.nixos.org/packages" ["nix" "dev"])
                  (bm "NixOS Plasma Manager Search" "https://nix-community.github.io/plasma-manager/options.xhtml" ["nix" "dev"])
                  (bm "NixOS Home Manager Search" "https://home-manager-options.extranix.com/" ["nix" "dev"])
                  (bm "NixOS Noogle Search" "https://noogle.dev/" ["nix" "dev"])
                ];
              }
            ];
          };
        };

        Work = {
          id = 1;
          name = "Work";
          path = "work";
          settings = commonSettings;
        };

        Midtfyns = {
          id = 2;
          name = "Midtfyns Festival";
          path = "midtfyns";
          settings = commonSettings;

          bookmarks = {
            force = true;
            settings = [
              {
                name = "Workspace";
                toolbar = true;
                bookmarks = [
                  (bm "Asana" "https://app.asana.com/" ["work"])
                  (bm "Outlook" "https://outlook.office.com/mail/" ["work"])
                  (bm "Teams" "https://teams.microsoft.com/" ["work"])
                ];
              }
              {
                name = "Development";
                toolbar = true;
                bookmarks = [
                  (bm "MailTrap" "https://mailtrap.io/sandboxes/4555739/settings" ["dev"])
                  (bm "Claude" "https://claude.ai/" ["dev"])
                ];
              }
              {
                name = "Sandbox Bagland";
                toolbar = true;
                bookmarks = [
                  (bm "Front" "https://mf-bagland-staging.azurewebsites.net/" ["dev"])
                  (bm "Admin" "https://mf-bagland-staging.azurewebsites.net/admin" ["dev"])
                ];
              }
            ];
          };
        };

        H = {
          id = 3;
          name = "H";
          path = "h";
          settings = commonSettings;
        };
      };
    };

    xdg.desktopEntries = {
      firefox-home = mkLauncher "Home" "Personal Browser";
      firefox-work = mkLauncher "Work" "Work Browser";
      firefox-midtfyns = mkLauncher "Midtfyns Festival" "Midtfyns Browser";
      firefox-h = mkLauncher "H" "H Browser";

      firefox-profile-manager = {
        name = "Firefox — Profile Manager";
        genericName = "Manage Firefox Profiles";
        exec = "firefox -P";
        icon = "firefox";
        terminal = false;
        categories = ["Network" "WebBrowser"];
      };
    };
  }
