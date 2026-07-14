{inputs, ...}: {
  # 1. Explicitly define all inputs
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-file.url = "github:vic/flake-file";
    colmena.url = "github:zhaofengli/colmena";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    preservation.url = "github:WilliButz/preservation";
    disko.url = "github:nix-community/disko";
    agenix.url = "github:ryantm/agenix";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-shell.url = "github:aciceri/agenix-shell";
    home-manager.url = "github:nix-community/home-manager/master";
    plasma-manager.url = "github:nix-community/plasma-manager";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    antigravity-nix.url = "github:jacopone/antigravity-nix";
    nixvim.url = "github:nix-community/nixvim";
    nix-index-database.url = "github:nix-community/nix-index-database";
    git-hooks.url = "github:cachix/git-hooks.nix";
    arion.url = "github:hercules-ci/arion";
    import-tree.url = "github:denful/import-tree";
    comin.url = "github:nlewo/comin";
  };

  systems = inputs.nixpkgs.lib.systems.flakeExposed;

  imports = [
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.nix-auto-follow
    inputs.agenix-rekey.flakeModule
    inputs.agenix-shell.flakeModules.default
    inputs.home-manager.flakeModules.home-manager

    # The modular handoffs
    ./hosts.nix
    ./shell.nix
  ];
}
