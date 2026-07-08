{pkgs, ...}: {
  enable = true;

  colorschemes.catppuccin.enable = true;

  plugins = {
    neo-tree = {
      enable = true;
      settings = {
        enable_diagnostics = true;
        enable_git_status = true;
      };
    };
    telescope.enable = true;
    lualine.enable = true;
    lsp = {
      enable = true;
      servers = {
        nixd.enable = true; # Nix support
        pyright.enable = true;
      };
    };
    auto-save.enable = true;

    conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          nix = ["alejandra"];
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
      };
    };

    lint = {
      enable = true;
      lintersByFt = {
        nix = ["statix" "deadnix"];
      };
    };
  };

  extraPackages = with pkgs; [
    statix
    deadnix
    alejandra
    nixd
  ];

  globals.mapleader = " ";

  keymaps = [
    {
      key = "<leader>e";
      action = "<cmd>Neotree toggle<CR>";
    }
    {
      key = "<leader>ff";
      action = "<cmd>Telescope find_files<CR>";
    }
  ];

  opts = {
    number = true;
    shiftwidth = 2;
    expandtab = true;
  };
}
