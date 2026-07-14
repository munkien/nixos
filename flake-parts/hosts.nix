{inputs, ...}: let
  hosts = {
    pc-anders = {
      system = "x86_64-linux";
      tags = ["workstations"];
      targetHost = null;
      targetUser = "munkien";
      privilegeEscalationCommand = ["sudo" "-H" "--"];
    };
    server-home-1 = {
      system = "x86_64-linux";
      tags = ["servers"];
      targetHost = "192.168.88.218";
      targetUser = "munkien";
      privilegeEscalationCommand = ["sudo" "-H" "--"];
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
