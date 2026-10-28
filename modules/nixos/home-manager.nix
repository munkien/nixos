{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  environment = {
    systemPackages = [pkgs.home-manager];
  };

  # Global Home Manager Integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs;};
    sharedModules = [
      # The fleet vocabulary is declared once in profile.nix and is read from
      # both sides of the NixOS/Home Manager split, so Home Manager needs the
      # declarations too. It is imported here rather than by copying the options
      # into modules/home, which is what the two option modules used to do.
      ./profile.nix
      (inputs.import-tree ../home)
    ];
  };
}
