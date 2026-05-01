{
  description = "Munkiens Fleet: Multi-Arch, Auto-Updating, and Declarative";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    antigravity-nix.url = "github:jacopone/antigravity-nix";
    antigravity-nix.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "";

    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-rekey.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    plasma-manager.url = "github:nix-community/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    colmena.url = "github:zhaofengli/colmena";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [inputs.agenix-rekey.flakeModule]; # Removed profiles.nix from flake-parts scope

      flake = let
        inherit (inputs.nixpkgs) lib;

        defaultUsers = [
          {
            name = "munkien";
            system = ./users/munkien/default.nix;
            home = ./users/munkien/home.nix;
          }
        ];

        sharedNixosModules = with inputs; [
          agenix.nixosModules.default
          agenix-rekey.nixosModules.default
          ({config, ...}: {
            age.rekey = {
              masterIdentities = ["~/.ssh/id_ed25519"];
              storageMode = "local";
              localStorageDir = ./hosts/${config.networking.hostName}/secrets;
            };
          })
          impermanence.nixosModules.impermanence
          disko.nixosModules.disko
          quadlet-nix.nixosModules.quadlet
          nix-index-database.nixosModules.nix-index
        ];

        sharedHomeModules = with inputs; [
          plasma-manager.homeModules.plasma-manager
          nix-flatpak.homeManagerModules.nix-flatpak
          agenix.homeManagerModules.default
        ];

        hosts = {
          pc-anders = {
            system = "x86_64-linux";
            deployment = {
              targetHost = "pc-anders";
              tags = ["workstations"];
              allowLocalDeployment = true;
            };
          };
          server-home-1 = {
            system = "x86_64-linux";
            deployment = {
              targetHost = "server-home-1";
              tags = ["servers"];
            };
          };
          pc-kiosk-browser = {
            system = "x86_64-linux";
            deployment = {
              targetHost = "pc-kiosk-browser";
              tags = ["workstations" "kiosks"];
            };
          };
          server-datalix-1 = {
            system = "x86_64-linux";
            deployment = {
              targetHost = "server-datalix-1";
              tags = ["servers"];
            };
          };
        };

        mkHostModules = {
          hostname,
          system,
          users ? defaultUsers,
        }:
          [
            {
              networking.hostName = hostname;
              nixpkgs.hostPlatform = system;
            }
            ./hosts/${hostname}

            ./modules/profiles.nix

            ./modules/gaming.nix
            ./modules/desktop.nix
            ./modules/containers.nix

            ./modules/common
          ]
          ++ sharedNixosModules
          ++ map (u: u.system) users
          ++ lib.optionals (builtins.length users > 0) [
            inputs.home-manager.nixosModules.home-manager
            ({config, ...}: {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit inputs;
                  hostConfig = config.my;
                };
                sharedModules = sharedHomeModules;
                users = builtins.listToAttrs (map (u: {
                    inherit (u) name;
                    value = import u.home;
                  })
                  users);
              };
            }) # Added the missing parenthesis here
          ];
      in {
        nixosConfigurations =
          lib.mapAttrs (
            hostname: host:
              lib.nixosSystem {
                inherit (host) system;
                specialArgs = {inherit inputs;};
                modules = mkHostModules {
                  inherit hostname;
                  inherit (host) system;
                };
              }
          )
          hosts
          // {
            rescue = lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {inherit inputs;};
              modules = [{nixpkgs.hostPlatform = "x86_64-linux";} ./hosts/rescue/default.nix];
            };
          };

        colmenaHive = inputs.colmena.lib.makeHive (
          {
            meta = {
              nixpkgs = import inputs.nixpkgs {system = "x86_64-linux";};
              specialArgs = {inherit inputs;};
            };
          }
          // lib.mapAttrs (hostname: host: {
            inherit (host) deployment;
            imports = mkHostModules {
              inherit hostname;
              inherit (host) system;
            };
          })
          hosts
        );
      };

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        checks.pre-commit-check = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;
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

        agenix-rekey.nodes = builtins.removeAttrs self.nixosConfigurations ["rescue"];

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
