{pkgs, ...}: {
  imports = [
    ./plasma.nix

    ./apps/terminal.nix
    ./apps/git.nix
    ./apps/firefox.nix
    ./apps/thunderbird.nix
    ./apps/quickemu.nix
    ./apps/gaming.nix
    ./apps/vscodium.nix
    ./apps/irssi.nix
  ];

  # Home Manager setup
  home.username = "munkien";
  home.homeDirectory = "/home/munkien";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  # Housekeeping
  systemd.user.tmpfiles.rules = [
    "e %h/.cache - - - 7d -"
  ];

  # Packages
  home.packages = with pkgs; [
    # System util
    wl-clipboard
    btrfs-assistant
    headsetcontrol
    kdePackages.kate

    # ISO writer to USB
    woeusb-ng

    # Privacy
    tor-browser

    # Media & Socials
    discord
    spotify

    # Remote Desktop
    moonlight-qt
  ];
}
