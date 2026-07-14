{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  # Global Home Manager Integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    sharedModules = [
      inputs.plasma-manager.homeModules.plasma-manager
      inputs.nix-flatpak.homeManagerModules.nix-flatpak
      inputs.agenix.homeManagerModules.default
      inputs.nixvim.homeModules.nixvim
    ];
  };
}
