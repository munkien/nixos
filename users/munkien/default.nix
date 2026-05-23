{
  config,
  pkgs,
  lib,
  inputs,
  isDesktop ? false,
  isGaming ? false,
  ...
}: {
  # System-level identity
  age.secrets."munkien_password_hashed" = {
    file = ./password.age; # relative path, must exist
    symlink = false;
    path = "/etc/age-secrets/munkien_password_hashed";
  };

  imports = [
    ./desktop/ananicy.nix
  ];

  services.jotta-cli.enable = true;
  programs.fish.enable = true;

  # Open ports
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      53317 # LocalSend
      8043 # Omada Web UI
      8088 # Omada HTTP Portal
      8843 # Omada HTTPS Portal
      29811
      29812
      29813
      29814
      29815
      29816 # Omada Management & Discovery
      29817 # Omada Controller Telemetry
    ];

    allowedUDPPorts = [
      53317 # LocalSend
      29810 # Omada Discovery
    ];
  };

  users.users.munkien = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."munkien_password_hashed".path;
    description = "Anders";
    extraGroups = ["networkmanager" "wheel" "podman" "docker"];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [(lib.strings.trim (builtins.readFile ./userPubkey.pub))];
  };

  # User-level environment
  home-manager.users.munkien = {pkgs, ...}: {
    programs.home-manager.enable = true;
    home = {
      username = "munkien";
      homeDirectory = "/home/munkien";
      stateVersion = "26.05";
    };
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
      ++ lib.optionals isDesktop [
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
      ++ lib.optionals isGaming [
        ./desktop/gaming.nix
      ];

    home.packages = with pkgs;
      lib.optionals isDesktop [
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
      ++ lib.optionals isDesktop [
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
        signal-desktop
        zenmap
        podman-desktop
        pods
        variety
        proton-pass
        protonmail-desktop
        proton-vpn
        rclone
      ];
  };
}
