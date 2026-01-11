{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.username = "munkien";
  home.homeDirectory = "/home/munkien";
  home.stateVersion = "25.11";

  home.sessionVariables = {
    QUICKEMU_VMDIR = "/scratch/quickemu";
  };

  # Cleaning up
  systemd.user.tmpfiles.rules = [
    "e %h/.cache - - - 30d -"
  ];

  programs.plasma = {
    enable = true;
    workspace = {
    };

    panels = [
      # Panel på hovedskærmen (0)
      {
        location = "top";
        height = 26;
        widgets = ["org.kde.plasma.appmenu"];
      }
      {
        location = "bottom";
        height = 44;
        screen = 0;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                launchers = [
                  "applications:firefox.desktop"
                  "applications:thunderbird.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:codium.desktop"
                  "applications:systemsettings.desktop"
                ];
              };
            };
          }
        ];
      }
      # Panel på sekundær skærm (1)
      {
        location = "bottom";
        height = 44;
        screen = 1;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
      {
        location = "top";
        height = 26;
        widgets = ["org.kde.plasma.appmenu"];
      }
    ];
  };

  home.packages = with pkgs; [
    tor-browser
    cliphist
    wl-clipboard
    discord
    btrfs-assistant
    vscodium
    headsetcontrol
    spotify
    heroic
    fractal
  ];

  # Fractal Configuration
  dconf.settings = {
    "org/gnome/Fractal" = {
      "view-sidebar" = true;
      "window-maximized" = false;
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles.munkien = {
      isDefault = true;
      settings = {
        "calendar.timezone.useSystemTimezone" = true;
        "calendar.timezone.local" = "Europe/Copenhagen";
        "intl.regional_prefs.use_os_locales" = true;
      };
    };
  };
  home.file.".thunderbird/munkien/feeds.json".text = builtins.toJSON [
    {
      url = "https://nixos.org/blogs.xml";
      title = "NixOS Blog";
    }
    {
      url = "https://news.ycombinator.com/rss";
      title = "Hacker News";
    }
  ];

  stylix.targets.firefox.profileNames = ["munkien"];
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
      };
    };
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
            ];
          }
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
      };
    };
  };

  programs.bash.enable = true;
  services.ssh-agent.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "munkien";
        email = "munkien@gmail.com";
      };
      init = {
        defaultBranch = "master";
      };
      pull = {
        rebase = true;
      };
      core.editor = "nano";
      core.sshCommand = "ssh -i ~/.ssh/id_ed25519 -F /dev/null";
      push.autoSetupRemote = "true";
    };
  };

  # Lad Home Manager styre sig selv
  programs.home-manager.enable = true;
}
