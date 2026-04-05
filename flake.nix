{
  description = "Munkiens Fleet: Multi-Arch, Auto-Updating, and Declarative";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
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
    deploy-rs = {
      url = "github:serokell/deploy-rs";
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

  outputs = inputs @ {self, ...}:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [inputs.git-hooks.flakeModule];

      perSystem = {
        config,
        pkgs,
        ...
      }: {
        pre-commit.settings.hooks = {
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
            entry = "${pkgs.nix}/bin/nix flake check --no-build";
            pass_filenames = false;
          };
        };

        # nix run .#build-rescue
        apps.build-rescue = {
          type = "app";
          meta.description = "Build and copy rescue ISO to /scratch";
          program = "${pkgs.writeShellApplication {
            name = "build-rescue-iso";
            runtimeInputs = with pkgs; [coreutils findutils nix];
            text = ''
              echo "Building Rescue ISO..."
              OUT_PATH=$(nix build --print-out-paths --no-link .#rescueConfigurations.usb-rescue.config.system.build.isoImage --impure)
              ISO_FILE=$(find "$OUT_PATH/iso" -name "*.iso" | head -n 1)
              [ -z "$ISO_FILE" ] && echo "Error: ISO not found" && exit 1
              mkdir -p /scratch
              cp --reflink=auto "$ISO_FILE" /scratch/rescue-usb.iso
              chmod 644 /scratch/rescue-usb.iso
              echo "Success! ISO ready at /scratch/rescue-usb.iso"
            '';
          }}/bin/build-rescue-iso";
        };
      };

      flake = let
        # Default users — override per host as needed
        defaultUsers = [
          {
            name = "munkien";
            system = ./users/munkien/default.nix;
            home = ./users/munkien/home.nix;
          }
        ];

        # Build a NixOS system
        mkSystem = {
          hostname,
          system,
          users ? defaultUsers,
          modules ? [],
        }:
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {inherit inputs;};
            modules =
              # System-level user modules
              (map (u: u.system) users)
              ++ [
                inputs.agenix.nixosModules.default
                inputs.impermanence.nixosModules.impermanence
              ]
              # Home Manager — only when users are present
              ++ inputs.nixpkgs.lib.optionals (users != []) [
                inputs.home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    extraSpecialArgs = {inherit inputs;};
                    sharedModules = [
                      inputs.plasma-manager.homeModules.plasma-manager
                      inputs.nix-flatpak.homeManagerModules.nix-flatpak
                      inputs.agenix.homeManagerModules.default
                    ];
                    # Dynamically assign home config per user
                    users = builtins.listToAttrs (map (u: {
                        name = u.name;
                        value = import u.home;
                      })
                      users);
                  };
                }
              ]
              # Optional per-host files — only loaded if they exist
              ++ builtins.filter builtins.pathExists [
                ./hosts/${hostname}/default.nix
                ./hosts/${hostname}/hardware.nix
                ./hosts/${hostname}/hardware-configuration.nix
                ./hosts/${hostname}/filesystem.nix
                ./hosts/${hostname}/disko.nix
              ]
              # Disko — only when host has a disko.nix
              ++ inputs.nixpkgs.lib.optional
              (builtins.pathExists ./hosts/${hostname}/disko.nix)
              inputs.disko.nixosModules.disko
              ++ modules;
          };

        # Build a deploy-rs node
        mkNode = configName: targetAddress: system: {
          # targetAddress defines WHERE deploy-rs connects via SSH
          hostname = targetAddress;
          fastConnection = true;
          profiles.system = {
            user = "root";
            sshUser = "root";
            path =
              inputs.deploy-rs.lib.${system}.activate.nixos
              # configName defines WHICH configuration to build
              self.nixosConfigurations.${configName};
          };
        };
      in {
        nixosConfigurations = {
          pc-anders = mkSystem {
            hostname = "pc-anders";
            system = "x86_64-linux";
          };

          server-home-1 = mkSystem {
            hostname = "server-home-1";
            system = "x86_64-linux";
            users = [];
            modules = [inputs.quadlet-nix.nixosModules.quadlet];
          };

          # server-media-1 = mkSystem {
          #   hostname = "server-media-1";
          #   system = "x86_64-linux";
          #   users = [];
          # };
        };

        # Rescue USB — intentionally minimal, outside mkSystem
        usb-rescue = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs;};
          modules = [
            ./hosts/usb-rescue/default.nix
            inputs.agenix.nixosModules.default
          ];
        };

        deploy.nodes = {
          # Usage: mkNode <configName> <IP/Domain> <Architecture>
          pc-anders = mkNode "pc-anders" "pc-anders" "x86_64-linux";
          server-home-1 = mkNode "server-home-1" "192.168.0.50" "x86_64-linux";
          #server-media-1 = mkNode "server-media-1" "server-media-1" "x86_64-linux";
        };

        checks =
          builtins.mapAttrs
          (_: deployLib: deployLib.deployChecks self.deploy)
          inputs.deploy-rs.lib;
      };
    };
}
