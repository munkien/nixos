{
  config,
  pkgs,
  inputs,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];
  security.sudo.wheelNeedsPassword = false;
  programs.nix-ld.enable = true;
  programs.nix-index.enable = true;
  nixpkgs.config.allowUnfree = true;
  programs.git.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  console.keyMap = "dk-latin1";

  # Time, Dr. Freeman?
  time.timeZone = "Europe/Copenhagen";
  services.timesyncd = {
    enable = true;
    servers = [
      "pool.ntp.org"
    ];
    fallbackServers = [
      "time.google.com"
    ];
  };

  # Enable networking
  networking.wireless.enable = true;
  networking.networkmanager.enable = true;

  # NH Helper :)
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.dates = "daily";
    clean.extraArgs = "--keep-since 30d --keep 10";
    flake = "/home/munkien/nixos";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.initrd.systemd.enable = true;

  # Auto upgrade
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    allowReboot = true;
    randomizedDelaySec = "1hr";
    rebootWindow = {
      lower = "23:00";
      upper = "06:00";
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };
  # Configure OOMd
  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableUserSlices = true;
    enableSystemSlice = true;
  };

  # Configure builds and store
  nix.settings.auto-optimise-store = true;
  nix.settings.max-jobs = "auto";
  nix.settings.cores = 0;

  # Sandbox
  nix.settings.sandbox = true;

  # Configure tuned
  services.tuned = {
    enable = true;
    settings.dynamic_tuning = true;
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
      ServerAliveInterval 60
      ServerAliveCountMax 3
    '';
  };
  programs.mosh.enable = true;
  networking.firewall.allowedTCPPorts = [22];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 60000;
      to = 61000;
    }
  ];

  # HDD monitoring
  services.smartd.enable = !config.virtualisation.hypervGuest.enable;

  # Stuff.
  environment.systemPackages = with pkgs; [
    tuned
    treefmt
    alejandra
    wget
    git
    nil
    deadnix
    quickemu
    pre-commit
    comma
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
