{pkgs, ...}: {
  home.packages = with pkgs; [
    nixfmt
    nixpkgs-fmt
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
        "editor.formatOnSave" = true;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";

        "nix.serverSettings" = {
          "nixd" = {
            "formatting" = {"command" = ["nixfmt"];};
            "options" = {
              "nixos" = {
                "expr" = "(builtins.getFlake \"/home/munkien/nixos\").nixosConfigurations.workstation.options";
              };
              "home-manager" = {
                "expr" = "(builtins.getFlake \"/home/munkien/nixos\").homeConfigurations.munkien.options";
              };
            };
          };
        };

        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "workbench.colorTheme" = "Tokyo Night";
      };
    };
  };
}
