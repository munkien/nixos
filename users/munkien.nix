{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.impermanence.nixosModules.home-manager.impermanence];

  home.username = "munkien";
  home.homeDirectory = "/home/munkien";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    firefox
    tor-browser
    cliphist
    wl-clipboard
    discord
    btrfs-assistant
  ];

  home.persistence."/persist/home/munkien" = {
    allowOther = true;
    directories = [
      "nixos"
      ".mozilla"
      ".local/share/direnv"
      ".local/share/kate"
      ".ssh"
      ".config/discord"
      ".local/share/discord"
      ".steam"
      ".local/share/Steam"
    ];
    files = [
      ".config/katerc"
      ".config/katevirc"
      ".config/katemetainfos"
      ".config/kateschemarc"
      ".bash_history"
    ];
  };

  programs.firefox = {
    enable = true;
    profiles.munkien = {
      isDefault = true;

      # 1. Indstillinger (about:config)
      settings = {
        "browser.aboutConfig.showWarning" = false;
        "browser.startup.homepage" = "https://nixos.org";
        "browser.newtabpage.enabled" = false;

        # Privacy & Sikkerhed
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "dom.security.https_only_mode" = true;
        "browser.shell.checkDefaultBrowser" = false;

        # Performance (Hardware acceleration)
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
      };

      # 2. Søgemaskiner
      search = {
        default = "DuckDuckGo";
        force = true;
      };

      # 3. Udvidelser (Extensions)
      # Bemærk: Dette kræver ofte 'firefox-addons' input i din flake
      # Hvis du ikke har det endnu, kan de installeres manuelt i starten
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bitwarden
        darkreader
      ];
    };
  };

  # Det er god stil at aktivere disse specifikt
  programs.bash.enable = true;
  programs.kitty.enable = true;

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
