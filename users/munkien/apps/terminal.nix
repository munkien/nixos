{
  lib,
  ...
}: {
  programs.bash.enable = true;

  programs.kitty = {
    enable = true;
    themeFile = "tokyo_night_night";

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    settings = {
      shell = "fish";
      scrollback_lines = 10000;
      copy_on_select = "yes";
      mouse_hide_wait = 0;
      background_opacity = "0.85";
      dynamic_background_opacity = "yes";
      hide_window_decorations = "no";
      confirm_os_window_close = 0;
    };

    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      gcp = "git add . && git commit -m 'WIP' && git push";
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;

      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$package"
        "$line_break"
        "$character"
      ];

      scan_timeout = 10;

      character = {
        success_symbol = "➜";
        error_symbol = "X➜";
      };

      directory = {
        truncation_length = 3;
        style = "bold blue";
      };
    };
  };
}
