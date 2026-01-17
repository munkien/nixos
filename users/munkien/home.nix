{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  plasmaPanelCommon = {
    location = "bottom";
    height = 40;
    widgets = [
      "org.kde.plasma.kickoff"

      "org.kde.plasma.panelspacer"

      {
        name = "org.kde.plasma.icontasks";
        config.General.launchers = [
          "applications:codium.desktop"
          "applications:kitty.desktop"
          "applications:firefox.desktop"
          "applications:org.gnome.Fractal.desktop"
          "applications:systemsettings.desktop"
        ];
      }

      "org.kde.plasma.panelspacer"

      {
        name = "org.kde.plasma.systemmonitor.net";
        config.General.displayStyle = "org.kde.ksysguard.textonly";
      }

      {
        name = "org.kde.plasma.systemmonitor";
        config.General.sensors = ["cpu/all/usage" "mem/physical/usedpercent"];
      }

      "org.kde.plasma.clipboard"
      "org.kde.plasma.systemtray"
      "org.kde.plasma.digitalclock"
    ];
  };
in {
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
    "e %h/.cache - - - 14d -"
  ];

  programs.plasma = {
    enable = true;
    panels = [
      (plasmaPanelCommon // {screen = 0;})
      (plasmaPanelCommon // {screen = 1;})
    ];
  };

  home.activation.linkSteamDriveC = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn /scratch/battle.net $VERBOSE_ARG /home/munkien/.local/share/Steam/steamapps/compatdata/2232372708/pfx/drive_c
  '';

  home.packages = with pkgs; [
    tor-browser
    cliphist
    wl-clipboard
    discord
    btrfs-assistant
    vscodium
    headsetcontrol
    spotify
    gh

    fractal
    fish
    nixd
    nixpkgs-fmt

    # Game Clients
    heroic

    # Games
    dwarf-fortress-full
    liquidwar
    openttd
    tbe
  ];

  services.flatpak = {
    enable = true;
    update = {
      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };
    packages = ["net.openra.OpenRA"];
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          "nixd" = {
            "formatting" = {"command" = ["nixpkgs-fmt"];};
            "options" = {
              "nixos" = {
                "expr" = "(builtins.getFlake \"/home/munkien/nixos\").nixosConfigurations.workstation.options";
              };
              "home-manager" = {
                "expr" = "(builtins.getFlake \"/home/munkien/nixos\").homeConfigurations.munkien.options";
              };
            };
          };
        };
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
    };
  };

  programs.kitty = {
    enable = true;
    themeFile = "tokyo_night_night";
    shellIntegration.enableFishIntegration = true;
    enableGitIntegration = true;
    actionAliases = {
      "gcp" = "git add . && git commit -m WIP && git push";
    };
    settings = {
      shell = "fish";
      scrollback_lines = 10000;
      copy_on_select = "yes";
      mouse_hide_wait = 0;
    };
    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
    };
  };

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
