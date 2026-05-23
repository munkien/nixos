{inputs, ...}: let
  globalModules = {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
      inputs.stylix.nixosModules.stylix
      inputs.quadlet-nix.nixosModules.quadlet
      inputs.home-manager.nixosModules.home-manager
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
      inputs.nix-index-database.nixosModules.default
    ];

    age.rekey.masterIdentities = ["/home/munkien/.ssh/id_ed25519"];

    # Apply global configurations that all hosts should share
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        inputs.plasma-manager.homeModules.plasma-manager
        inputs.nix-index-database.homeModules.nix-index
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
      ];
    };
  };
in {
  pc-anders = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      isDesktop = true;
      isGaming = true;
    };
    modules = [
      globalModules
      {
        home-manager.extraSpecialArgs = {
          inherit inputs;
          isDesktop = true;
          isGaming = true;
        };
      }
      ../modules/core/default.nix
      ./pc-anders
      ../users/munkien/default.nix
    ];
  };

  server-home-1 = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs;
      isDesktop = false;
      isGaming = false;
    };
    modules = [
      globalModules
      {
        home-manager.extraSpecialArgs = {
          inherit inputs;
          isDesktop = false;
          isGaming = false;
        };
      }
      ../modules/core/default.nix
      ./server-home-1
      ../users/munkien/default.nix
    ];
  };
  ##
}
