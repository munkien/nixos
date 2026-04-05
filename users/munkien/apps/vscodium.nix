{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    nixd
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
        "remote.SSH.useLocalServer" = true;
        "remote.SSH.showLoginTerminal" = true;
        "workbench.colorTheme" = "Tokyo Night";
        "editor.formatOnSave" = true;

        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
          "editor.formatOnSave" = true;
        };

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";

        "nix.serverSettings" = {
          nixd = {
            formatting.command = [ "${pkgs.alejandra}/bin/alejandra" ];
            options = {
              nixos."expr" = "(builtins.getFlake \"path:/home/munkien/nixos\").nixosConfigurations.pc-anders.options";
              home-manager."expr" = "(builtins.getFlake \"path:/home/munkien/nixos\").nixosConfigurations.pc-anders.options.home-manager.users.type.functor.wrapped";
            };
          };
        };
      };
    };
  };
}