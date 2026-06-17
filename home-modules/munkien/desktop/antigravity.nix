{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
    nixd
    direnv
    gh
    inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-no-fhs
  ];

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;
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
        };

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";

        "containers.containerClient" = "com.microsoft.visualstudio.containers.podman";
        "containers.orchestratorClient" = "com.microsoft.visualstudio.orchestrators.podmancompose";
        "dev.containers.dockerPath" = "podman";
        "docker.dockerPath" = "podman";
        "docker.host" = "unix:///run/user/1000/podman/podman.sock";
        "dev.containers.dockerComposePath" = "podman-compose";
        "docker.composeCommand" = "podman-compose";

        "nix.serverSettings" = {
          nixd = {
            formatting.command = ["${pkgs.alejandra}/bin/alejandra"];
            options = {
              "nixos" = {
                "expr" = "(builtins.getFlake \"/home/munkien/nixos\").nixosConfigurations.pc-anders.options";
              };
              "home-manager" = {
                "expr" = "(builtins.getFlake \"/home/munkien/nixos\").homeConfigurations.pc-anders.options";
              };
            };
          };
        };
      };
    };
  };
}
