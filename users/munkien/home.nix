{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
    ../../mods/user/apps/steam.nix
  ];

  home.username = "munkien";
  home.homeDirectory = "/home/munkien";
  home.stateVersion = "25.11";

  home.persistence."/persist" = {
    directories = [
      ".mozilla/firefox"
      ".local/share/tor-browser"
      ".local/share/kate"

      ".config/discord"
      ".cache/discord"

      ".local/share/kwalletd"
      {
        directory = ".gnupg";
        mode = "0700";
      }
      {
        directory = ".ssh";
        mode = "0700";
      }
      {
        directory = ".nixops";
        mode = "0700";
      }
      {
        directory = ".local/share/keyrings";
        mode = "0700";
      }
      ".local/share/direnv"
    ];

    files = [
      ".bash_history"
      ".screenrc"
      ".config/katerc"
      ".config/katevirc"
      ".config/katemetainfos"
      ".config/kateschemarc"
    ];
  };

  programs.plasma = {
    enable = true;
    workspace = {
    };

    panels = [
      # Panel på hovedskærmen (0)
      {
        location = "bottom";
        height = 44;
        screen = 0;
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
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
  ];

  programs.zsh.initExtra = ''
    gcp() {
      git add .
      git commit -m "$1"
      git push
    }
  '';

  stylix.targets.firefox.profileNames = ["munkien"];

  programs.firefox = {
    enable = true;
    policies.ExtensionSettings = {
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        installation_mode = "force_installed";
      };
    };
    profiles.munkien = {
      isDefault = true;
      name = "munkien";
      id = 0;
      path = "munkien";
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
      push.autoSetupRemote = "true";
    };
  };

  # Lad Home Manager styre sig selv
  programs.home-manager.enable = true;
}
