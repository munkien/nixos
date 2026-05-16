# Add hostConfig to the top
{
  pkgs,
  inputs,
  lib,
  hostConfig,
  ...
}: {
  home = {
    username = "munkien";
    homeDirectory = "/home/munkien";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  systemd.user.tmpfiles.rules = [
    "X %h/.cache/nix - - - -"
    "e %h/.cache - - - 7d -"
  ];

  imports =
    [
      ./common/git.nix
      ./common/ssh.nix
      ./common/terminal.nix
    ]
    ++ lib.optionals hostConfig.profiles.desktop.enable [
      ./desktop/antigravity.nix
      ./desktop/firefox.nix
      ./desktop/logitech.nix
      ./desktop/irssi.nix
      ./desktop/media.nix
      ./desktop/plasma.nix
      ./desktop/productivity.nix
      ./desktop/quickemu.nix
      ./desktop/thunderbird.nix
    ]
    ++ lib.optionals hostConfig.profiles.gaming.enable [
      ./desktop/gaming.nix
    ];

  home.packages = with pkgs;
    lib.optionals hostConfig.profiles.developer.enable [
      inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-no-fhs
      alejandra
      nixd
      bat
      deadnix
      eza
      kdePackages.kio-extras
      statix
      treefmt
      pre-commit
      deploy-rs
    ]
    ++ lib.optionals hostConfig.profiles.desktop.enable [
      wl-clipboard
      btrfs-assistant
      headsetcontrol
      kdePackages.kate
      winbox4
      woeusb-ng
      moonlight-qt
      rustdesk
      localsend
      freerdp
      zenmap
      podman-desktop
      pods
    ];
}
