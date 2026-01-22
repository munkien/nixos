{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  bcachefsStatus = pkgs.writeShellScript "bcachefs-status.sh" ''
    # Sti til dit specifikke filesystem
    SYS_PATH="/sys/fs/bcachefs/fe8de683-7e92-4cc0-ace2-8ce2bccfa296"

    if [ ! -d "$SYS_PATH" ]; then
      echo "BFS: NOT FOUND"
      exit 1
    fi

    USAGE=$(cat "$SYS_PATH/internal/usage_stats")

    # State check (Hurtigere end list_volumes hvis sysfs tillader det)
    # Men vi beholder din version da den er mest præcis på tværs af versioner
    STATE=$(${pkgs.bcachefs-tools}/bin/bcachefs list_volumes / | grep -q "failed\|ro" && echo "!!DEGRADED!!" || echo "OK")

    # Pending Reconcile parsing
    PENDING_RAW=$(echo "$USAGE" | grep "reconcile:" | awk '{print $2}')

    # Simpel men effektiv advarsels-logik:
    # Hvis strengen indeholder 'G' (Gigabyte) eller 'T' (Terabyte), giv advarsel.
    WARN=""
    if [[ "$PENDING_RAW" =~ [GT] ]]; then
        WARN="⚠️ "
    fi

    USED=$(echo "$USAGE" | grep "data:" | awk '{print $2}')

    echo "BFS: $STATE | $USED | ''${WARN}Pnd: $PENDING_RAW"
  '';

  panelsDefinition = [
    {
      location = "top";
      height = 30;
      widgets = [
        "org.kde.plasma.lock_logout"
        "org.kde.plasma.panelspacer"
        {
          name = "org.kde.plasma.commandoutput";
          config = {
            General = {
              # The command to run (using your bcachefsStatus variable)
              command = "${bcachefsStatus}";
              # Refresh interval in seconds (e.g., 60 seconds)
              interval = 60;
              # Appearance
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
        "org.kde.plasma.mediacontroller"
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
    overrideConfig = false;
    panels = lib.flatten [
      (map (p: p // {screen = 0;}) panelsDefinition)
      (map (p: p // {screen = 1;}) panelsDefinition)
    ];

    workspace = {
      lookAndFeel = "com.github.vinceliuice.Sweet";
      iconTheme = "candy-icons";
      cursorTheme = "Sweet-cursors";
      colorScheme = "Sweet";
    };

    kwin = {
      effects = {
        blur.enable = true;
        translucency.enable = true;
        fps.enable = false; # Set to true if you're debugging performance
      };
    };

    configFile = {
      # Force Kvantum as the widget provider for transparency
      "kdeglobals"."KDE"."widgetStyle" = "kvantum";

      # Configure Blur Intensity (Value 0-20)
      "kwinrc"."Plugins"."blurRadius" = 12;

      # Set specific window transparency for inactive windows
      "kwinrc"."Plugins"."translucencyOpaque" = 85;

      # Enable the "Magic Lamp" animation for that futuristic look
      "kwinrc"."Plugins"."magiclampEnabled" = true;
    };
  };

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=Sweet
  '';

  gtk = {
    enable = true;
    theme = {
      name = lib.mkForce "Sweet-Dark";
    };
    iconTheme = {
      name = "candy-icons";
    };
  };
  home.sessionVariables.GTK_THEME = "Sweet-Dark";

  # Steam
  home.activation.linkSteamDriveC = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn /scratch/battle.net $VERBOSE_ARG /home/munkien/.local/share/Steam/steamapps/compatdata/2232372708/pfx/drive_c
  '';

  # Packages
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

    kdePackages.kate
    moonlight

    fish
    nixfmt
    nixpkgs-fmt

    # Theming / Plasma6
    sweet-nova
    candy-icons
    kdePackages.qtstyleplugin-kvantum

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
      url."git@github.com:".insteadOf = "https://github.com/";
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

  programs.home-manager.enable = true;
}
