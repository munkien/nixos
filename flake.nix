{
  description = "munkiens flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager-stable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs-unstable,
    home-manager-unstable,
    sops-nix,
    impermanence,
    ...
  } @ inputs: {
    nixosConfigurations = {
      desktop = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/desktop/desktop.nix
          ./hosts/desktop/hardware.nix
          ./hosts/desktop/storage.nix

          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          home-manager-unstable.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.munkien = import ./users/munkien.nix;
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
      };
    };
  };
}
