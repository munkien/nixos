{
  pkgs,
  lib,
  inputs,
  osConfig,
  ...
}: {
  programs.home-manager.enable = true;
  home = {
    username = "munkien";
    homeDirectory = "/home/munkien";
    stateVersion = "26.05";
  };
  systemd.user.tmpfiles.rules = [
    "X %h/.cache/nix - - - -"
    "e %h/.cache - - - 7d -"
  ];

  imports = [
    ../../common/home
    (inputs.import-tree ../../modules/home)
  ];

  services.ssh-agent.enable = true;

  programs.git = {
    enable = true;

    signing = {
      key = "~/.ssh/id_ed25519.pub";
      format = "ssh";
    };

    settings = {
      gpg.format = "ssh";
      commit.gpgsign = true;
      user.signingkey = "~/.ssh/id_ed25519.pub";
      url."git@github.com:".insteadOf = "https://github.com/";
      user = {
        name = "munkien";
        email = "munkien@gmail.com";
      };
      init.defaultBranch = "master";
      pull.rebase = true;
      core.editor = "nano";
      push.autoSetupRemote = "true";
    };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = [pkgs.kdePackages.xdg-desktop-portal-kde];
      config.common.default = "kde";
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };
    configFile."mimeapps.list".force = true;
  };

  home.packages = with pkgs;
    lib.optionals osConfig.my.graphical.enable [
      bat
      eza
      kdePackages.kio-extras
      deploy-rs
      wl-clipboard
      headsetcontrol
      winbox4
      keepassxc
      woeusb-ng
      moonlight-qt
      rustdesk
      localsend
      freerdp
      signal-desktop
      obsidian
      zenmap
      podman-desktop
      pods
      variety
      proton-pass
      protonmail-desktop
      proton-vpn
      rclone
      libreoffice-qt-fresh
      tor-browser
      wezterm
    ];

  my.autostart =
    lib.optionals osConfig.my.graphical.enable [
      {
        name = "Spotify";
        exec = "${pkgs.spotify}/bin/spotify";
      }
      {
        name = "Discord";
        exec = "${pkgs.discord}/bin/discord";
      }
    ]
    ++ lib.optionals osConfig.my.gaming.enable [
      {
        name = "Steam";
        exec = "${pkgs.steam}/bin/steam -silent";
      }
      {
        name = "Heroic";
        exec = "${pkgs.heroic}/bin/heroic";
      }
      {
        name = "Lutris";
        exec = "${pkgs.lutris}/bin/flatpak run --branch=stable --arch=x86_64 --command=lutris --file-forwarding net.lutris.Lutris @@u %U @@";
      }
    ];
}
