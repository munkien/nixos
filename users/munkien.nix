{
  config,
  pkgs,
  inputs,
  ...
}: {
imports = [ inputs.impermanence.nixosModules.home-manager.impermanence ];

  home.username = "munkien";
  home.homeDirectory = "/home/munkien";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    firefox
    cliphist
    wl-clipboard
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
    ];
    files = [
      ".config/katerc"
      ".config/katevirc"
      ".config/katemetainfos"
      ".config/kateschemarc"
      ".bash_history"
    ];
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
