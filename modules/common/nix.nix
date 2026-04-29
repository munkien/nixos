{
  config,
  lib,
  ...
}: {
  options.my.flakeDir = lib.mkOption {
    type = lib.types.str;
    default = "/home/munkien/nixos";
    description = "Path to the system flake directory";
  };

  config = {
    nix.settings = {
      keep-outputs = true;
      keep-derivations = true;
      experimental-features = ["nix-command" "flakes"];
      sandbox = true;
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0;
      download-attempts = 5;
      trusted-users = ["root" "@wheel"];
      connect-timeout = 5;
      fallback = true;
      warn-dirty = false;
      download-buffer-size = 67108864;
      tarball-ttl = 604800;
    };

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;

    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.dates = "daily";
      clean.extraArgs = "--keep-since 30d --keep 10";
      flake = config.my.flakeDir;
    };
  };
}
