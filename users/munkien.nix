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
    kitty
    wofi
    waybar
    grim
    slurp
    cliphist
    wl-clipboard
  ];

  # Det er god stil at aktivere disse specifikt
  programs.bash.enable = true;
  programs.kitty.enable = true;

  programs.ssh = {
    enable = true;
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

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
