{
  description = "Munkiens Fleet: Strictly Declarative Multi-Arch NixOS";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Deployments & Hardware Context
    colmena.url = "github:zhaofengli/colmena";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # State & Partitioning
    preservation.url = "github:WilliButz/preservation";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets Management
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-rekey.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager & User Environment
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    # System Utilities & Tooling
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    antigravity-nix.url = "github:jacopone/antigravity-nix";
    antigravity-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];

      imports = [inputs.agenix-rekey.flakeModule];

      flake = let
        # --- 1. THE DEPLOYED FLEET ---
        hosts = {
          pc-anders = {
            system = "x86_64-linux";
            tags = ["workstations"];
          };
          server-home-1 = {
            system = "x86_64-linux";
            tags = ["servers"];
          };
          #           pc-kiosk-browser = {
          #             system = "x86_64-linux";
          #             tags = ["workstations" "kiosks"];
          #           };
          #           server-datalix-1 = {
          #             system = "x86_64-linux";
          #             tags = ["servers"];
          #           };
        };

        # --- 2. THE UNIVERSAL PAYLOAD ---
        sharedModules = [
          inputs.disko.nixosModules.disko
          inputs.agenix.nixosModules.default
          inputs.agenix-rekey.nixosModules.default
          inputs.preservation.nixosModules.preservation
          inputs.nix-index-database.nixosModules.nix-index
          inputs.nix-flatpak.nixosModules.nix-flatpak
          inputs.quadlet-nix.nixosModules.quadlet

          ./common/options.nix

          ({config, ...}: {
            age.rekey = {
              masterIdentities = ["~/.ssh/id_ed25519"];
              storageMode = "local";
              localStorageDir = ./hosts/${config.networking.hostName}/secrets;
            };
            users.users.root.hashedPassword = "$y$jFT$G4A4efQj5fPKiajbtllMI.$0.ejwCo57NJ5Vw0plf9lK9cIp3rVIeqfMKwZeJCDUXD";
          })

          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs;};
            home-manager.sharedModules = [
              inputs.plasma-manager.homeModules.plasma-manager
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
              inputs.agenix.homeManagerModules.default
              inputs.nixvim.homeModules.nixvim
            ];
          }
        ];

        # --- 3. THE BUILDERS ---
        mkHost = name: host:
          nixpkgs.lib.nixosSystem {
            inherit (host) system;
            specialArgs = {inherit inputs;};
            modules =
              sharedModules
              ++ [
                ./hosts/${name}
                {networking.hostName = name;}
              ];
          };

        mkColmenaNode = name: host: {
          imports =
            sharedModules
            ++ [
              ./hosts/${name}
              {networking.hostName = name;}
            ];
          deployment = {
            targetHost = name;
            tags = host.tags;
          };
        };

        # Evaluate the main fleet configurations
        fleetConfigurations = builtins.mapAttrs mkHost hosts;
      in {
        # --- 4. EXPORTED CONFIGURATIONS ---

        # Merge the heavy fleet with the lightweight rescue ISO
        nixosConfigurations =
          fleetConfigurations;
        # // {
        #   rescue = nixpkgs.lib.nixosSystem {
        #     system = "x86_64-linux";
        #     specialArgs = {inherit inputs;};
        #     modules = [./hosts/rescue/default.nix];
        #   };
        # };

        homeConfigurations.munkien = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit inputs;
            osConfig = {
              my.graphical.enable = true;
              my.gaming.enable = true;
            };
          };
          modules =
            [
              ./users/munkien/home.nix
            ]
            ++ [
              inputs.plasma-manager.homeModules.plasma-manager
              inputs.nix-flatpak.homeManagerModules.nix-flatpak
              inputs.agenix.homeManagerModules.default
            ];
        };

        # Colmena only maps the deployed fleet
        colmenaHive = inputs.colmena.lib.makeHive ({
            meta = {
              nixpkgs = import inputs.nixpkgs {system = "x86_64-linux";};
              nodeNixpkgs = builtins.mapAttrs (name: host: import inputs.nixpkgs {system = host.system;}) hosts;
              specialArgs = {inherit inputs;};
            };
          }
          // builtins.mapAttrs mkColmenaNode hosts);
      };

      # --- 5. DEVELOPER ENVIRONMENT ---
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        # Inject the fleet into Agenix (excluding the rescue ISO)
        agenix-rekey.nodes = builtins.removeAttrs self.nixosConfigurations ["rescue"];

        checks.pre-commit-check = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            check-symlinks.enable = true;
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (config.checks.pre-commit-check) shellHook;
          buildInputs =
            config.checks.pre-commit-check.enabledPackages
            ++ [
              config.agenix-rekey.package
              inputs.colmena.packages.${system}.colmena
            ];
        };
      };
    };
}
