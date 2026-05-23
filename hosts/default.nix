{inputs, ...}: let
  globalModules = {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
      inputs.stylix.nixosModules.stylix
      inputs.nix-flatpak.nixosModules.nix-flatpak
      inputs.quadlet-nix.nixosModules.quadlet
      inputs.home-manager.nixosModules.home-manager
    ];

    # Apply global configurations that all hosts should share
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        inputs.plasma-manager.homeManagerModules.plasma-manager
        inputs.nix-index-database.hmModules.nix-index
      ];
    };
  };
in {
  pc-anders = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit inputs;};
    modules = [
      ./hosts/pc-anders
      globalModules
    ];
  };
}
