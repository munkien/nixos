{inputs, ...}: let
  hosts = {
    pc-anders = {
      system = "x86_64-linux";
      tags = ["workstations"];
    };
    server-home-1 = {
      system = "x86_64-linux";
      tags = ["servers"];
    };
  };

  commonModules = name: [
    ../hosts/${name}
    {networking.hostName = name;}

    (inputs.import-tree ../modules/nixos)
  ];

  mkHost = name: host:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (host) system;
      specialArgs = {inherit inputs;};
      modules = commonModules name;
    };
in {
  flake = {
    nixosConfigurations = builtins.mapAttrs mkHost hosts;
  };
}
