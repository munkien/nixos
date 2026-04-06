{
  description = "Munkiens Fleet: Multi-Arch, Auto-Updating, and Declarative";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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

  outputs = inputs @ {self, ...}: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = inputs.nixpkgs.lib.genAttrs systems;

    defaultUsers = [
      {
        name = "munkien";
        system = ./users/munkien/default.nix;
        home = ./users/munkien/home.nix;
      }
    ];

    # 1. Centralized External Dependencies
    sharedNixosModules = with inputs; [
      agenix.nixosModules.default
      impermanence.nixosModules.impermanence
      disko.nixosModules.disko
      quadlet-nix.nixosModules.quadlet
    ];

    sharedHomeModules = with inputs; [
      plasma-manager.homeModules.plasma-manager
      nix-flatpak.homeManagerModules.nix-flatpak
      agenix.homeManagerModules.default
    ];

    # 2. The Single Source of Truth
    fleet = {
      pc-anders = {
        system = "x86_64-linux";
        deployIp = "pc-anders";
      };
      server-home-1 = {
        system = "x86_64-linux";
        deployIp = "192.168.0.50";
      };
    };

    # System Builder
    mkSystem = {
      hostname,
      system,
      users ? defaultUsers,
    }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules =
          [{nixpkgs.hostPlatform = system;}]
          ++ (map (u: u.system) users)
          ++ sharedNixosModules
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
          ]
          ++ [
            (inputs.import-tree ./hosts/${hostname})
            (inputs.import-tree ./modules)
          ];
      };

    # Deploy-RS Node Builder
    mkNode = configName: targetAddress: system: {
      hostname = targetAddress;
      fastConnection = true;
      profiles.system = {
        user = "root";
        sshUser = "root";
        path =
          inputs.deploy-rs.lib.${system}.activate.nixos
          self.nixosConfigurations.${configName};
      };
    };
  in {
    # Generated NixOS Configurations
    nixosConfigurations =
      builtins.mapAttrs (name: hostConfig:
        mkSystem {
          hostname = name;
          system = hostConfig.system;
          users = hostConfig.users or defaultUsers;
        })
      fleet
      // {
        # Manually appended utility configuration
        usb-rescue = inputs.nixpkgs.lib.nixosSystem {
          nixpkgs.hostPlatform = "x86_64-linux";
          specialArgs = {inherit inputs;};
          modules = sharedNixosModules ++ [./hosts/usb-rescue/default.nix];
        };
      };

    # 6. Generated Deployment Nodes
    deploy.nodes =
      builtins.mapAttrs (name: hostConfig: mkNode name hostConfig.deployIp hostConfig.system) fleet;

    # 7. Multi-Arch Tooling
    apps = forAllSystems (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      build-rescue = {
        type = "app";
        meta.description = "Build and copy rescue ISO to /scratch";
        program = "${pkgs.writeShellApplication {
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
        }}/bin/build-rescue-iso";
      };
    });

    checks = forAllSystems (system: let
      deployChecks = inputs.deploy-rs.lib.${system}.deployChecks self.deploy;
      pre-commit-check = inputs.git-hooks.lib.${system}.run {
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
    in
      deployChecks // {inherit pre-commit-check;});

    devShells = forAllSystems (system: let
      pkgs = import inputs.nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    });
  };
}
