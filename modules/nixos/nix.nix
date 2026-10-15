{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options.my.flakeDir = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "/home/munkien/nixos";
    description = ''
      Path to a locally checked-out copy of this flake, used only to configure
      `nh` as a convenience wrapper. Deployment does NOT depend on this: comin
      deploys from its own clone under /var/lib/comin, and evaluation reads the
      flake from the nix store.

      Set per host. Defaults to null so a host without a local checkout (e.g. a
      kiosk) does not get an `nh` pointed at a path that does not exist.
    '';
  };

  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];

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
        # Only point nh at a checkout when the host actually declares one. The
        # previous `config.my.flakeDir or "..."` was dead code: the option had a
        # default, so `or` could never fire.
        flake = lib.mkIf (config.my.flakeDir != null) config.my.flakeDir;
        clean = {
          enable = true;
          dates = "daily";
          extraArgs = "--keep-since 7d --keep 5";
        };
      };
    };

    systemd.services.nix-daemon.serviceConfig = {
      Nice = lib.mkForce 19;
      IOSchedulingClass = lib.mkForce "idle";
    };
  };
}
