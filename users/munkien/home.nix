{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.impermanence.homeManagerModules.impermanence
  ];

  home.username = "munkien";
  home.homeDirectory = "/home/munkien";
  home.stateVersion = "25.11";

  home.persistence."/persist/home/munkien" = {
    allowOther = true;
    directories = [
      ".mozilla/firefox/munkien"
      ".local/share/tor-browser"
      ".local/share/direnv"
      ".local/share/kate"
      ".config/discord"
      ".local/share/discord"
      ".steam"
      ".local/share/Steam"
      ".local/share/keyrings"
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

  home.packages = with pkgs; [
    firefox
    tor-browser
    cliphist
    wl-clipboard
    discord
    btrfs-assistant
  ];

  programs.zsh.initExtra = ''
    gcp() {
      git add .
      git commit -m "$1"
      git push
    }
  '';

  programs.firefox = {
    enable = true;
    profiles.munkien = {
      isDefault = true;
      name = "munkien";
      id = 0;
      path = "munkien";
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
