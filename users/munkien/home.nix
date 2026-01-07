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
    tor-browser
    cliphist
    wl-clipboard
    discord
    btrfs-assistant
    vscodium
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

  # Det er god stil at aktivere disse specifikt
  programs.bash.enable = true;
  programs.kitty.enable = true;

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
