{
  pkgs,
  inputs,
  lib,
  osConfig,
  config,
  ...
}:
lib.mkIf (osConfig.my.desktop.enable && config.my.user.developer.enable) {
  home.packages = with pkgs; [
    alejandra
    statix
    treefmt
    pre-commit
    kdePackages.kate
    nixd
    direnv
    nil
    gh
    inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-no-fhs
    code-cursor
    mqttx
  ];

  programs.vscodium = {
    enable = true;

    profiles.default = {
      # Inject the Nix IDE extension
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];

      # Lock down the settings (prevents manual GUI overrides)
      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.serverSettings" = {
          nixd = {
            formatting = {
              command = ["alejandra"];
            };
          };
        };

        # Enforce clean code
        "editor.formatOnSave" = true;
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
      };
    };
  };
}
