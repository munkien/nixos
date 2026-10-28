{inputs, ...}: let
  # Every host is a directory under hosts/ containing a default.nix.
  #
  # This module used to hold a separate table listing each host's system and
  # tags. That table disagreed with the host files themselves: a host's
  # `my.desktop.enable` and its entry in the table described the same fact in
  # two places, and `tags` was read by nothing. The inventory now comes from the
  # filesystem, and the only fact a host must state twice is its hostname,
  # which nixpkgs needs before the configuration can be evaluated.
  hasDefault = name: builtins.pathExists (../hosts + "/${name}/default.nix");

  names = builtins.filter hasDefault (builtins.attrNames (builtins.readDir ../hosts));

  # Hosts are discovered, but their platform has to be stated once, because
  # nixpkgs needs a platform before a host's configuration can be evaluated.
  # This is the one entry that must be added when introducing a host; everything
  # else about the host lives in its own directory.
  platforms = {
    pc-anders = "x86_64-linux";
    server-home-1 = "x86_64-linux";
  };

  mkHost = name:
    inputs.nixpkgs.lib.nixosSystem {
      system = platforms.${name};
      specialArgs = {inherit inputs;};
      modules = [
        ../hosts/${name}
        {networking.hostName = name;}
        (inputs.import-tree ../modules/nixos)
      ];
    };
in {
  # A host directory with no platform entry would be silently skipped, which is
  # worse than a broken build: the host would simply cease to exist. Fail loudly.
  flake.nixosConfigurations = assert inputs.nixpkgs.lib.assertMsg (names == builtins.attrNames platforms)
  "hosts/ and the platforms table disagree: ${toString names} vs ${toString (builtins.attrNames platforms)}";
    builtins.listToAttrs (
      map (name: {
        inherit name;
        value = mkHost name;
      })
      names
    );
}
