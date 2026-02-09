{
  pkgs,
  ...
}: {
  programs.firefox = {
    enable = true;
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
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
        "plasma-browser-integration@kde.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };

    nativeMessagingHosts = [pkgs.kdePackages.plasma-browser-integration];

    profiles.munkien = {
      isDefault = true;
      name = "munkien";
      id = 0;
      path = "munkien";

      search = {
        force = true;
        default = "ddg";
        engines = {
          "Nix Packages" = {
            urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
            icon = "https://nixos.org/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # 24 timer
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
            name = "Entertainment";
            toolbar = true;
            bookmarks = [
              {
                name = "YouTube";
                url = "https://youtube.com/";
                tags = ["entertainment"];
              }
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
  };
}
