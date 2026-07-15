{
  pkgs,
  lib,
  inputs,
  osConfig,
  config,
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
    (inputs.import-tree ../../modules/home)
  ];

  services.ssh-agent.enable = true;

  my.user = {
    media.enable = true;
    developer.enable = true;
    autostart = [
      "spotify"
      "vscodium"
      "discord"
      "steam"
      "lutris"
      "heroic"
    ];
  };

  services.flatpak.packages = [
    "net.openra.OpenRA"
    "com.play0ad.zeroad"
    "com.remnantsoftheprecursors.ROTP"
    "info.beyondallreason.bar"
    "com.revolutionarygamesstudio.ThriveLauncher"
  ];

  programs.lutris.enable = true;

  home.activation.linkSteamDriveC = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn /scratch/battle.net $VERBOSE_ARG ${config.home.homeDirectory}/.local/share/Steam/steamapps/compatdata/2232372708/pfx/drive_c
  '';

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
      safe = {
        directory = [
          "/home/munkien/nixos"
        ];
      };
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
    lib.optionals osConfig.my.desktop.enable [
      kdePackages.kio-extras
      wl-clipboard
      headsetcontrol
      winbox4
      keepassxc
      woeusb-ng
      moonlight-qt
      rustdesk
      localsend
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

      # Gaming
      heroic
      satisfactorymodmanager
      liquidwar
      tbe
      rimsort
    ]
    ++ [
      bat
      eza
    ];
}
