{pkgs, ...}: {
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
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.dates = "daily";
    clean.extraArgs = "--keep-since 30d --keep 10";
    flake = "/home/munkien/nixos"; # worth making this an option
  };
}
