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
    package = pkgs.vscodium-fhsWithPackages (ps: with ps; [rustup zlib alejandra]);

    profiles.default = {
      # Inject the Nix IDE extension
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        continue.continue
        skellock.just
        ((pkgs.vscode-utils.extensionFromVscodeMarketplace {
            name = "open-remote-ssh";
            publisher = "jeanp413";
            version = "0.0.45";
            sha256 = "sha256-YoeUNvxLSmy3OftZp2AnqRU+TKe3KYLt3zZ0B5XGgeE=";
          }).overrideAttrs (old: {
            src = pkgs.fetchurl {
              url = "https://github.com/jeanp413/open-remote-ssh/releases/download/v0.0.45/open-remote-ssh-0.0.45.vsix";
              hash = "sha256-YoeUNvxLSmy3OftZp2AnqRU+TKe3KYLt3zZ0B5XGgeE=";
            };
          }))
        kamadorueda.alejandra
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

  home.file.".continue/config.yaml".source = (pkgs.formats.yaml {}).generate "continue-config" {
    name = "Local Config";
    version = "1.0.0";
    schema = "v1";
    models = [
      {
        name = "Autodetect";
        provider = "ollama";
        model = "AUTODETECT";
      }
    ];
  };
}
