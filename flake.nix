# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: import ./outputs.nix inputs;

  inputs = {
    agenix.url = "github:ryantm/agenix";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    agenix-shell.url = "github:aciceri/agenix-shell";
    antigravity-nix.url = "github:jacopone/antigravity-nix";
    arion.url = "github:hercules-ci/arion";
    colmena.url = "github:zhaofengli/colmena";
    disko.url = "github:nix-community/disko";
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
    home-manager.url = "github:nix-community/home-manager/master";
    nix-auto-follow = {
      url = "github:fzakaria/nix-auto-follow";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    plasma-manager.url = "github:nix-community/plasma-manager";
    preservation.url = "github:WilliButz/preservation";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
  };
}
