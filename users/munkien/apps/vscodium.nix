{pkgs, ...}: {
  home.packages = with pkgs; [
    nixfmt
    nixd
    nil
    direnv
    gh
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        mkhl.direnv
        enkia.tokyo-night
      ];

      userSettings = {
        # Combined settings into one block
        "remote.SSH.useLocalServer" = true;
        "remote.SSH.showLoginTerminal" = true;
        "editor.formatOnSave" = true;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "workbench.colorTheme" = "Tokyo Night";

        "nix.serverSettings" = {
          "nixd" = {
            "formatting" = {"command" = ["nixfmt"];};
            "options" = {
              "nixos" = {
                # Ensure the path is absolute and the configuration name matches your flake.nix
                "expr" = "(builtins.getFlake \"/home/munkien/nixos\").nixosConfigurations.workstation.options";
              };
              "home-manager" = {
                "expr" = "(builtins.getFlake \"/home/munkien/nixos\").homeConfigurations.munkien.options";
              };
            };
          };
        };
      };
    };
  };
}
