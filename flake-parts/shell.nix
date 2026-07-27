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
        deadnix.enable = false;
        statix.enable = false;
        check-symlinks.enable = true;
        ripsecrets.enable = true;
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
