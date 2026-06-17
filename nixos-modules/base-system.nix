{
  inputs,
  lib,
  ...
}: {
  imports = [
    ../nixos-modules/core

    inputs.disko.nixosModules.disko
    inputs.preservation.nixosModules.preservation
    inputs.stylix.nixosModules.stylix
    inputs.quadlet-nix.nixosModules.quadlet
    inputs.home-manager.nixosModules.home-manager
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
    inputs.nix-index-database.nixosModules.default
  ];

  options = {
    isDesktop = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this system is a desktop/laptop or not. Affects various desktop-related configurations.";
    };
    isGaming = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this system is used for gaming. Affects various gaming-related configurations.";
    };
  };

  config = {
    # Root password
    users.users.root.hashedPassword = "$y$jFT$G4A4efQj5fPKiajbtllMI.$0.ejwCo57NJ5Vw0plf9lK9cIp3rVIeqfMKwZeJCDUXD";

    # Global secret configuration
    age.rekey.masterIdentities = ["/home/munkien/.ssh/id_ed25519"];
    age.identityPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    # Global Home-Manager config
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [
        inputs.plasma-manager.homeModules.plasma-manager
        inputs.nix-index-database.homeModules.nix-index
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.agenix.homeManagerModules.default
      ];
      extraSpecialArgs = {inherit inputs;};
    };
  };
}
