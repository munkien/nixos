{
  config,
  lib,
  pkgs,
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
      extra-substituters = [
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    nixpkgs.config.allowUnfree = true;

    programs = {
      nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          openssl
          libGL
          libgpg-error
          libxml2
          libX11
          libXext
          libXcursor
          libXinerama
          libXi
          libXrandr
          libXrender
          libXScrnSaver
          libXxf86vm
          libxkbcommon
          libpulseaudio
          alsa-lib
        ];
      };

      nix-index.enable = true;
      nix-index-database.comma.enable = true;

      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      nh = {
        enable = true;
        flake = config.my.flakeDir;
        clean = {
          enable = true;
          dates = "daily";
          extraArgs = "--keep-since 30d --keep 10";
        };
      };
    };

    systemd.services.nix-daemon.serviceConfig = {
      Nice = lib.mkForce 19;
      IOSchedulingClass = lib.mkForce "idle";
    };
  };
}
