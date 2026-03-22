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
    impermanence.url = "github:nix-community/impermanence";
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
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
          check-added-large-files = {
            enable = true;
            args = ["--maxkb=2000"];
          };
          check-symlinks.enable = true;
          check-yaml = {
            enable = true;
            excludes = [".*sops\\.yaml$"];
          };
          flake-check = {
            enable = true;
            name = "Fast Flake Check";
            entry = "${pkgs.nix}/bin/nix flake check --no-build";
            pass_filenames = false;
          };
        };

        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${config.pre-commit.installationScript}
            shopt -s globstar
            if [ -f .sops.yaml ]; then
              ${pkgs.sops}/bin/sops updatekeys -y **/*.sops.yaml 2>/dev/null || true
            fi
          '';
          packages = with pkgs; [sops age ssh-to-age alejandra];
        };

        apps.build-rescue = {
          type = "app";
          meta.description = "Rescue ISO";
          program = "${pkgs.writeShellApplication {
            name = "build-rescue-iso";
            runtimeInputs = [pkgs.coreutils pkgs.findutils pkgs.nix];
            text = ''
              echo "Building Rescue ISO..."
              OUT_PATH=$(nix build --print-out-paths --no-link .#nixosConfigurations.rescue-usb.config.system.build.isoImage)
              ISO_FILE=$(find "$OUT_PATH/iso" -name "*.iso" | head -n 1)
              [ -z "$ISO_FILE" ] && echo "Error: ISO not found" && exit 1
              DEST="/scratch/rescue-usb.iso"
              mkdir -p /scratch
              cp --reflink=auto "$ISO_FILE" "$DEST"
              chmod 644 "$DEST"
              echo "Success! ISO ready at $DEST"
            '';
          }}/bin/build-rescue-iso";
        };
      };

      flake = {
        lib.mkSystem = {
          hostname,
          system,
          enableHomeManager ? true,
          modules ? [],
        }:
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = {inherit inputs;};
            modules =
              [
                ./users/munkien/default.nix
                inputs.agenix.nixosModules.default
              ]
              ++ (inputs.nixpkgs.lib.optionals enableHomeManager [
                inputs.home-manager.nixosModules.home-manager
                {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    sharedModules = [
                      inputs.plasma-manager.homeModules.plasma-manager
                      inputs.nix-flatpak.homeManagerModules.nix-flatpak
                      inputs.agenix.homeManagerModules.default
                    ];
                    users.munkien = import ./users/munkien/home.nix;
                  };
                }
              ])
              ++ (builtins.filter builtins.pathExists [
                ./hosts/${hostname}/default.nix
                ./hosts/${hostname}/filesystem.nix
                ./hosts/${hostname}/hardware.nix
                ./hosts/${hostname}/hardware-configuration.nix
                ./hosts/${hostname}/disko.nix
              ])
              ++ (inputs.nixpkgs.lib.optional
                (builtins.pathExists ./hosts/${hostname}/disko.nix)
                inputs.disko.nixosModules.disko)
              ++ modules;
          };

        nixosConfigurations = {
          workstation = self.lib.mkSystem {
            hostname = "workstation";
            system = "x86_64-linux";
          };

          server-home-1 = self.lib.mkSystem {
            hostname = "server-home-1";
            system = "x86_64-linux";
            enableHomeManager = false;
            modules = [inputs.quadlet-nix.nixosModules.quadlet];
          };

          pc-anders = self.lib.mkSystem {
            hostname = "pc-anders";
            system = "x86_64-linux";
          };

          rescue-usb = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [./hosts/rescue/default.nix];
          };
        };
      };
    };
}
