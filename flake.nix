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
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [inputs.agenix-rekey.flakeModule];

      flake = let
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
        ];

        sharedHomeModules = with inputs; [
          plasma-manager.homeModules.plasma-manager
          nix-flatpak.homeManagerModules.nix-flatpak
          agenix.homeManagerModules.default
        ];

        mkHost = {
          hostname,
          system,
          users ? defaultUsers,
        }:
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {inherit inputs;};
            modules =
              [
                {networking.hostName = hostname;}
                (inputs.import-tree ./hosts/${hostname})
                (inputs.import-tree ./modules)
              ]
              ++ sharedNixosModules
              ++ map (u: u.system) users
              ++ inputs.nixpkgs.lib.optionals (users != []) [
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
          };
      in {
        nixosConfigurations = {
          pc-anders = mkHost {
            hostname = "pc-anders";
            system = "x86_64-linux";
          };
          server-home-1 = mkHost {
            hostname = "server-home-1";
            system = "x86_64-linux";
          };
          pc-kiosk-browser = mkHost {
            hostname = "pc-kiosk-browser";
            system = "x86_64-linux";
          };
          server-datalix-1 = mkHost {
            hostname = "server-datalix-1";
            system = "x86_64-linux";
          };

          usb-rescue = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = sharedNixosModules ++ [./hosts/usb-rescue/default.nix];
          };
        };
      };

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        apps.build-rescue = {
          type = "app";
          program = pkgs.lib.getExe (pkgs.writeShellApplication {
            name = "build-rescue-iso";
            runtimeInputs = with pkgs; [coreutils findutils nix];
            text = ''
              echo "Building Rescue ISO..."
              OUT_PATH=$(nix build --print-out-paths --no-link .#nixosConfigurations.usb-rescue.config.system.build.isoImage --impure)
              ISO_FILE=$(find "$OUT_PATH/iso" -name "*.iso" | head -n 1)
              [ -z "$ISO_FILE" ] && echo "Error: ISO not found" && exit 1
              mkdir -p /scratch
              cp --reflink=auto "$ISO_FILE" /scratch/rescue-usb.iso
              chmod 644 /scratch/rescue-usb.iso
              echo "Success! ISO ready at /scratch/rescue-usb.iso"
            '';
          });
        };

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
            ];
        };
      };
    };
}
