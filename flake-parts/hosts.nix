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

  mkHost = name: host:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (host) system;
      specialArgs = {inherit inputs;};
      modules = [
        ../common/core # Your sharedModules moved here
        ../hosts/${name}
        {networking.hostName = name;}
      ];
    };

  mkColmenaNode = name: host: {
    imports = [
      ../modules/core
      ../hosts/${name}
      {networking.hostName = name;}
    ];
    deployment = {
      targetHost = name;
      inherit (host) tags;
    };
  };
in {
  flake = {
    nixosConfigurations = builtins.mapAttrs mkHost hosts;

    colmenaHive = inputs.colmena.lib.makeHive ({
        meta = {
          nixpkgs = import inputs.nixpkgs {system = "x86_64-linux";};
          nodeNixpkgs = builtins.mapAttrs (_name: host: import inputs.nixpkgs {inherit (host) system;}) hosts;
          specialArgs = {inherit inputs;};
        };
      }
      // builtins.mapAttrs mkColmenaNode hosts);
  };
}
