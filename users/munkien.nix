{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.username = "munkien";
  home.homeDirectory = "/home/munkien";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    firefox
    cliphist
    wl-clipboard
  ];

  home.persistence."/persist/home/munkien" = {
    allowOther = true;
    directories = [
      "nixos"              # ~/nixos -> /persist/home/munkien/nixos
      ".local/share/kate"  # Gemmer dine Kate-indstillinger
      { directory = ".ssh"; mode = "0700"; } # Din personlige SSH med de rigtige rettigheder
    ];
    files = [
      ".config/katerc"
      ".config/katemetainfos"
      ".config/kateschemarc"
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
