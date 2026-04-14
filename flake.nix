{
  description = "Munkiens Fleet: Multi-Arch, Auto-Updating, and Declarative";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    colmena.url = "github:zhaofengli/colmena";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [inputs.agenix-rekey.flakeModule];

      flake = let
        inherit (inputs.nixpkgs) lib;

        # ── Users ────────────────────────────────────────────────────────────
        defaultUsers = [
          {
            name = "munkien";
            system = ./users/munkien/default.nix;
            home = ./users/munkien/home.nix;
          }
        ];

        # ── Shared module lists ───────────────────────────────────────────────
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
        ];

        sharedHomeModules = with inputs; [
          plasma-manager.homeModules.plasma-manager
          nix-flatpak.homeManagerModules.nix-flatpak
          agenix.homeManagerModules.default
        ];

        # ── Host inventory ────────────────────────────────────────────────────
        # Add deployment.* keys here to control colmena behaviour per-host.
        hosts = {
          pc-anders = {
            system = "x86_64-linux";
            deployment.targetHost = "pc-anders";
            deployment.tags = ["workstations"];
            deployment.allowLocalDeployment = true;
          };
          server-home-1 = {
            system = "x86_64-linux";
            deployment.targetHost = "server-home-1";
            deployment.tags = ["servers"];
          };
          pc-kiosk-browser = {
            system = "x86_64-linux";
            deployment.targetHost = "pc-kiosk-browser";
            deployment.tags = ["workstations" "kiosks"];
          };
          server-datalix-1 = {
            system = "x86_64-linux";
            deployment.targetHost = "server-datalix-1";
            deployment.tags = ["servers"];
          };
        };

        # ── Module composition ────────────────────────────────────────────────
        mkHostModules = {
          hostname,
          users ? defaultUsers,
        }:
          [
            {networking.hostName = hostname;}
            (inputs.import-tree ./hosts/${hostname})
            (inputs.import-tree ./modules)
          ]
          ++ sharedNixosModules
          ++ map (u: u.system) users
          ++ lib.optionals (users != []) [
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {inherit inputs;};
                sharedModules = sharedHomeModules;
                users = builtins.listToAttrs (map (u: {
                    inherit (u) name;
                    value = import u.home;
                  })
                  users);
              };
            }
          ];

        # ── nixosSystem wrapper ───────────────────────────────────────────────
        mkHost = {
          hostname,
          system,
          users ? defaultUsers,
        }:
          lib.nixosSystem {
            inherit system;
            specialArgs = {inherit inputs;};
            modules = mkHostModules {inherit hostname users;};
          };
      in {
        # Build all managed hosts plus the rescue image.
        nixosConfigurations =
          lib.mapAttrs (hostname: host:
            mkHost {
              inherit hostname;
              inherit (host) system;
            })
          hosts
          // {
            rescue = lib.nixosSystem {
              system = "x86_64-linux";
              specialArgs = {inherit inputs;};
              modules = [./hosts/rescue/default.nix];
            };
          };

        # Colmena deployment topology — derived from the same `hosts` inventory.
        colmenaHive = inputs.colmena.lib.makeHive (
          {
            meta = {
              # Default nixpkgs; overridden per-node via nodeNixpkgs.
              nixpkgs = import inputs.nixpkgs {system = "x86_64-linux";};
              nodeNixpkgs =
                lib.mapAttrs (
                  _: host: import inputs.nixpkgs {inherit (host) system;}
                )
                hosts;
              specialArgs = {inherit inputs;};
            };
          }
          // lib.mapAttrs (hostname: host: {
            deployment = host.deployment;
            imports = mkHostModules {inherit hostname;};
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

        devShells.default = pkgs.mkShell {
          inherit (config.checks.pre-commit-check) shellHook;
          buildInputs =
            config.checks.pre-commit-check.enabledPackages
            ++ [
              inputs.agenix-rekey.packages.${system}.default
              inputs.colmena.packages.${system}.colmena
            ];
        };
      };
    };
}
