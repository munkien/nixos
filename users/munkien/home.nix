{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./plasma.nix

    ./apps/terminal.nix
    ./apps/git.nix
    ./apps/firefox.nix
    ./apps/thunderbird.nix
    ./apps/quickemu.nix
    ./apps/gaming.nix
    ./apps/antigravity.nix
    ./apps/irssi.nix
  ];

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

    # Privacy
    tor-browser

    # Media & Socials
    discord
    spotify
    libreoffice-qt-fresh
    vlc
    mpv

    # Video editing
    kdePackages.kdenlive
    glaxnimate
    mediainfo
    handbrake
    ffmpeg-full

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
    nixos-anywhere
  ];
}
