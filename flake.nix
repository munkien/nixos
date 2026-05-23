{
  description = "Flake-parts NixOS & Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-shell.url = "github:aciceri/agenix-shell";

    antigravity-nix.url = "github:jacopone/antigravity-nix";
    antigravity-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    devshell.url = "github:numtide/devshell";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    impermanence.url = "github:nix-community/impermanence";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];

      imports = [
        inputs.agenix-rekey.flakeModule
        inputs.disko.flakeModules.default
        inputs.devshell.flakeModule
        inputs.git-hooks-nix.flakeModule
        inputs.home-manager.flakeModules.home-manager
        inputs.agenix-shell.flakeModules.default
      ];

      flake = {
        nixosConfigurations = import ./hosts {inherit inputs;};
      };

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        formatter = pkgs.alejandra;

        pre-commit.settings = {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            deadnix.enable = false;
            statix.enable = false;
            check-symlinks.enable = true;
            check-yaml.enable = true;
            check-added-large-files = {
              enable = true;
              args = ["--maxkb=2000"];
            };
            flake-check = {
              enable = true;
              name = "Fast Flake Check";
              entry = "nix flake check --no-build";
              pass_filenames = false;
            };
          };
        };

        devshells.default = {
          commands = [
            {package = pkgs.git;}
            {package = pkgs.nh;}
            {package = pkgs.age;}
            {package = pkgs.mkpasswd;}
            {package = inputs.agenix-rekey.packages.${pkgs.system}.default;}
          ];

          devshell.startup.pre-commit.text = config.pre-commit.installationScript;
          devshell.startup.ssh-add.text = ''ssh-add'';
        };
      };
    };
}
