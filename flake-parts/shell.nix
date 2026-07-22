{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: {
    checks.pre-commit-check = inputs.git-hooks.lib.${system}.run {
      src = ../.;
      hooks = {
        alejandra.enable = true;
        check-symlinks.enable = true;

        flake-checker = {
          enable = true;
          name = "flake-checker";
          entry = "nix run github:DeterminateSystems/flake-checker --";
          files = "flake.lock$";
          pass_filenames = false;
          stages = ["pre-push"];
        };
      };
    };

    devShells.default = pkgs.mkShell {
      inherit (config.checks.pre-commit-check) shellHook;
      buildInputs =
        config.checks.pre-commit-check.enabledPackages
        ++ [
          config.agenix-rekey.package
          inputs.colmena.packages.${system}.colmena
        ];
    };
  };
}
