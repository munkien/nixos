{
  description = "Munkiens Fleet: Multi-Arch, Auto-Updating, and Declarative";

  # ---------------------------------------------------------------
  # 1. INPUTS
  # ---------------------------------------------------------------
  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    # Framework
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Modules
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Extras
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  # ---------------------------------------------------------------
  # 2. OUTPUTS
  # ---------------------------------------------------------------
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # ===========================================================
      # A. PER-SYSTEM LOGIC (Apps & Checks)
      # ===========================================================
      perSystem = { config, pkgs, system, ... }: {
        
        # 1. Rescue ISO Builder Script
        # Usage: nix run .#build-rescue
        apps.build-rescue = {
          type = "app";
          program = "${pkgs.writeShellApplication {
            name = "build-rescue-iso";
            runtimeInputs = [ pkgs.coreutils pkgs.findutils pkgs.nix ];
            text = ''
              echo "🔨 Building Rescue ISO..."
              OUT_PATH=$(nix build --print-out-paths --no-link .#nixosConfigurations.rescue-usb.config.system.build.isoImage)
              ISO_FILE=$(find "$OUT_PATH/iso" -name "*.iso" | head -n 1)
              if [ -z "$ISO_FILE" ]; then echo "❌ Error: ISO not found"; exit 1; fi
              
              DEST="/scratch/rescue-usb.iso"
              echo "📂 Copying to $DEST..."
              mkdir -p /scratch
              cp --reflink=auto "$ISO_FILE" "$DEST"
              chmod 644 "$DEST"
              echo "✅ Success! ISO ready at $DEST"
            '';
          }}/bin/build-rescue-iso";
        };
      };

      # ===========================================================
      # B. GLOBAL LOGIC (The Hosts)
      # ===========================================================
      flake = {
        
        # 1. THE BUILDER FUNCTION
        # This reduces code duplication by 80%
        lib.mkSystem = { hostname, system, modules ? [] }: 
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            specialArgs = { inherit inputs; };
            modules = [
              # A. Auto-Import Host Config
              ./hosts/${hostname}/default.nix
              
              # B. Global Modules (Inject into EVERY system)
              ./modules/user-munkien.nix    # <--- Ensure this file exists!
              inputs.home-manager.nixosModules.home-manager
              inputs.sops-nix.nixosModules.sops
              
              # C. Host Specific Extras
            ] ++ modules;
          };

        # 2. THE CONFIGURATIONS
        nixosConfigurations = {
          
          # --- Workstation ---
          workstation = inputs.self.flake.lib.mkSystem {
            hostname = "workstation";
            system = "x86_64-linux";
            modules = [ 
              inputs.disko.nixosModules.disko 
              { home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ]; }
            ];
          };

          # --- Server ---
          server-x86 = inputs.self.flake.lib.mkSystem {
            hostname = "server-x86";
            system = "x86_64-linux";
            modules = [ inputs.disko.nixosModules.disko ];
          };

          # --- Cloud VM ---
          hetzner-vm = inputs.self.flake.lib.mkSystem {
            hostname = "hetzner-vm";
            system = "aarch64-linux";
            modules = [ inputs.disko.nixosModules.disko ];
          };

          # --- Raspberry Pi ---
          pi5 = inputs.self.flake.lib.mkSystem {
            hostname = "pi5";
            system = "aarch64-linux";
            modules = [ inputs.nixos-hardware.nixosModules.raspberry-pi-5 ];
          };

          # --- Rescue USB ---
          # Kept manual because it doesn't need users/sops/home-manager
          rescue-usb = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [ ./hosts/rescue-usb/default.nix ];
          };

        };
      };
    };
}
