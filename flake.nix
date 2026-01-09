{
  description = "munkiens flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
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
    stylix.url = "github:danth/stylix";
  };

  outputs = {
    self,
    nixpkgs-unstable,
    home-manager-unstable,
    plasma-manager,
    sops-nix,
    disko,
    impermanence,
    stylix,
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
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          home-manager-unstable.nixosModules.home-manager
          stylix.nixosModules.stylix

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.munkien = import ./users/munkien/home.nix;
            home-manager.extraSpecialArgs = {inherit inputs;};
          }
        ];
      };

      # Bootable ISO
      iso = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs-unstable}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"

          ({
            pkgs,
            lib,
            ...
          }: {
            boot.supportedFilesystems = lib.mkForce ["bcachefs" "btrfs"];
            boot.kernelPackages = pkgs.linuxPackages_latest;

            environment.systemPackages = with pkgs; [
              bcachefs-tools
              btrfs-progs
              gparted
              rsync
              git
              vim
            ];

            networking.networkmanager.enable = true;

            services.desktopManager.plasma6.enable = true;
            services.displayManager.sddm.enable = true;
            services.displayManager.defaultSession = "plasma";
            services.displayManager.autoLogin.enable = true;
            services.displayManager.autoLogin.user = "nixos";

            # Nødvendigt for at ISO'en ved den skal være bootbar
            isoImage.makeUsbBootable = true;
            isoImage.makeEfiBootable = true;
          })
        ];
      };
      #
    };
    packages.x86_64-linux.iso = self.nixosConfigurations.iso.config.system.build.isoImage;
  };
}
