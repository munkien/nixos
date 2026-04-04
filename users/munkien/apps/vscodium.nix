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
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
        "workbench.colorTheme" = "Tokyo Night";

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.formatterPath" = "${pkgs.alejandra}/bin/alejandra";

        "nix.serverSettings"."nixd" = {
          formatting.command = ["alejandra"];
          options = {
            # NixOS options — for system config completions
            nixos."expr" = "(builtins.getFlake \"path:/home/munkien/nixos\").nixosConfigurations.pc-anders.options";

            # Home Manager options — accessed through the NixOS module, not standalone
            home-manager."expr" = "(builtins.getFlake \"path:/home/munkien/nixos\").nixosConfigurations.pc-anders.options.home-manager.users.type.functor.wrapped";
          };
        };
      };
    };
  };
}
