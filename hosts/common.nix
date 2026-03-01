{
  config,
  pkgs,
  ...
}: {
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    experimental-features = ["nix-command" "flakes"];
    sandbox = true;
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0;
    download-attempts = 5;
    trusted-users = ["root" "munkien"];
    connect-timeout = 5;
    fallback = true;
    warn-dirty = false;
    download-buffer-size = 67108864;
    tarball-ttl = 604800; # 7 days in seconds
  };

  security.sudo.wheelNeedsPassword = false;
  programs.nix-ld.enable = true;
  programs.nix-index.enable = true;
  nixpkgs.config.allowUnfree = true;
  programs.git.enable = true;
  services.jotta-cli.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  console.keyMap = "dk-latin1";

  # Time, Dr. Freeman?
  time.timeZone = "Europe/Copenhagen";
  services.timesyncd.enable = false;
  networking.firewall.allowedUDPPorts = [123];
  services.chrony = {
    enable = true;
    initstepslew = {
      enabled = true;
      threshold = 1.0;
    };
    extraConfig = ''
      driftfile /var/lib/chrony/drift
      makestep 1.0 3
      pool pool.ntp.org iburst maxsources 5
    '';
  };

  # Enable networking
  networking = {
    wireless.enable = false;
    networkmanager = {
      enable = true;
      wifi.backend = "iwd";
    };
  };

  # Log file cleanup
  services.journald.extraConfig = ''
    SystemMaxUse=200M
    MaxFileSec=14day
  '';

  # Locate!
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "hourly";
  };

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
    dates = "04:00";
    allowReboot = true;
    randomizedDelaySec = "2hr";
    rebootWindow = {
      lower = "23:00";
      upper = "06:00";
    };
    flake = "git+ssh://git@github.com/munkien/nixos.git";
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

  # Configure tuned
  services.tuned = {
    enable = true;
    settings.dynamic_tuning = true;
  };

  # mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Root account failsafe - very strong password
  users.users.root = {
    hashedPassword = "$y$jFT$CiCF1yexMhqJzwW93W.tA1$Ta0ur3NW9HmlhDaDkHFh8sXK7e.6axUYY4GJjk4J0V4";
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
      Host github.com
        User git
        IdentityFile /etc/ssh/ssh_host_ed25519_key
        IdentitiesOnly yes
    '';
    knownHosts."github.com" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
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
    fastfetch
    deadnix
    statix
    pre-commit
    comma
    rustscan
    eza
    btop
    bat
    trippy
    ncdu
    pwgen
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions 196 wide x 243 height x 129 deep
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
