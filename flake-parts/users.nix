{
  inputs,
  osConfig,
  ...
}: {
  flake = {
    homeConfigurations.munkien = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      extraSpecialArgs = {
        inherit inputs;
        inherit osConfig;
      };

      modules = [
        ../users/munkien/home.nix
        {
          age.rekey = {
            masterIdentities = ["~/.ssh/id_ed25519"];
            storageMode = "local";
            localStorageDir = ../users/munkien/secrets;
          };
        }
        inputs.plasma-manager.homeModules.plasma-manager
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.agenix.homeManagerModules.default
        inputs.agenix-rekey.homeManagerModules.agenix-rekey
      ];
    };
  };
}
