{
  pkgs,
  inputs,
  config,
  lib,
  osConfig,
  ...
}: let
  desktopModules = lib.optionals osConfig.my.desktop.enable [
    (import ./plasma.nix {inherit pkgs inputs config lib osConfig;})
    (import ./apps/terminal.nix {inherit pkgs inputs config lib osConfig;})
    (import ./apps/git.nix {inherit pkgs inputs config lib osConfig;})
    (import ./apps/firefox.nix {inherit pkgs inputs config lib osConfig;})
    (import ./apps/thunderbird.nix {inherit pkgs inputs config lib osConfig;})
    (import ./apps/quickemu.nix {inherit pkgs inputs config lib osConfig;})
    (import ./apps/gaming.nix {inherit pkgs inputs config lib osConfig;})
    (import ./apps/antigravity.nix {inherit pkgs inputs config lib osConfig;})
    (import ./apps/irssi.nix {inherit pkgs inputs config lib osConfig;})
    (import ./apps/media.nix {inherit pkgs inputs config lib osConfig;})
    (import ./apps/productivity.nix {inherit pkgs inputs config lib osConfig;})
  ];
in
  lib.mkMerge (desktopModules
    ++ [
      {
        # Home Manager setup
        home.username = "munkien";
        home.homeDirectory = "/home/munkien";
        home.stateVersion = "25.11";
        programs.home-manager.enable = true;

        # Housekeeping
        systemd.user.tmpfiles.rules = [
          "X %h/.cache/nix - - - -"
          "e %h/.cache - - - 7d -"
        ];

        # SSH
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;

          matchBlocks = {
            "github.com" = {
              user = "git";
              identityFile = "~/.ssh/id_ed25519";
              identitiesOnly = true;
            };
            "homelab-local" = {
              hostname = "192.168.0.50";
              user = "munkien";
              identityFile = "~/.ssh/id_ed25519";
            };
          };
        };

        # Packages
        home.packages = with pkgs; [
          # System util
          wl-clipboard
          btrfs-assistant
          headsetcontrol
          kdePackages.kate
          winbox4

          # ISO writer to USB
          woeusb-ng
          #ventoy

          # Remote Desktop / access
          moonlight-qt
          rustdesk
          localsend

          # Programming
          inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-no-fhs
          alejandra # your formatter of choice
          nixd # your language server
          bat # your cat replacement
          deadnix # your nix linting workflow
          eza # your ls replacement
          statix # your nix linting workflow
          treefmt # your formatting workflow
          pre-commit # your dev workflow

          # Deployment
          deploy-rs
        ];
      }
    ])
