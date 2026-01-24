{
  description = "munkiens flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = {
    self,
    nixpkgs-unstable,
    home-manager-unstable,
    plasma-manager,
    sops-nix,
    disko,
    nix-flatpak,
    ...
  } @ inputs: {
    nixosConfigurations = {
      # Workstation
      workstation = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/workstation

          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          home-manager-unstable.nixosModules.home-manager

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [
                nix-flatpak.homeManagerModules.nix-flatpak
              ];
              users.munkien = import ./users/munkien/home.nix;
              extraSpecialArgs = {inherit inputs;};
            };
          }
        ];
      };

      # Bootable ISO
      installer = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          "${nixpkgs-unstable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
          ./hosts/installer/default.nix

          {
            nixpkgs.config.allowBroken = true;
            nix.settings.experimental-features = ["nix-command" "flakes"];
            nixpkgs.flake.source = nixpkgs-unstable.outPath;
          }
        ];
      };
    };
  };
}
