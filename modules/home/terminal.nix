{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fd
    ripgrep
  ];

  # Shell
  programs = {
    bash.enable = true; # Fallback

    fish = {
      enable = true;
      shellAliases = {
        gcp = "git status && git add . && git commit -m 'WIP' && git push";
        ls = "eza --icons --group-directories-first";
        cat = "bat";
        grep = "rg";
        find = "fd";
      };

      # Ensure Starship is initialized
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };

    # Integrates fzf directly into Fish using fd
    fzf = {
      enable = true;
      enableFishIntegration = true;

      defaultCommand = "fd --type f --hidden --exclude .git";
      fileWidget.command = "fd --type f --hidden --exclude .git";
      changeDirWidget.command = "fd --type d --hidden --exclude .git";
    };

    # 2. Terminal Emulator
    kitty = {
      enable = true;

      shellIntegration = {
        enableFishIntegration = true;
        enableBashIntegration = true;
      };

      settings = {
        shell = "fish";
        allow_remote_control = "no";
        auto_reload_config = 0;
        shell_integration = "enabled";

        # Visuals
        background_opacity = "0.85";
        dynamic_background_opacity = "yes";
        hide_window_decorations = "no";
        window_padding_width = 4;

        # UX
        scrollback_lines = 10000;
        copy_on_select = "yes";
        mouse_hide_wait = 0;
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
      };

      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
        "ctrl+v" = "paste_from_clipboard";
      };
    };

    # 3. Prompt (Starship)
    starship = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        add_newline = false;
        scan_timeout = 10;

        # Tokyo Night Palette Integration
        # We use standard ANSI colors which Kitty now maps to Tokyo Night
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_status"
          "$nix_shell"
          "$cmd_duration"
          "\n" # Explicit newline character is cleaner than $line_break
          "$character"
        ];

        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };

        directory = {
          truncation_length = 3;
          style = "bold blue";
          read_only = " 🔒";
        };

        git_branch = {
          style = "bold purple";
          symbol = " ";
        };

        git_status = {
          style = "bold red";
        };

        nix_shell = {
          symbol = "❄️ ";
          style = "bold cyan";
        };
      };
    };
  };
}
