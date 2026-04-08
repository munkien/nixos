{
  config,
  pkgs,
  ...
}: {
  my.impermanence.enable = true;
  my.autoUpgrade = {
    enable = true;
    flake = "github:munkien/nixos#pc-kiosk-browser";
  };

  # Define a restricted user for the kiosk
  users.users.kiosk = {
    isNormalUser = true;
    description = "Kiosk User";
  };

  # Enable Cage (Wayland Kiosk Compositor)
  services.cage = {
    enable = true;
    user = "kiosk";
    # Launch Firefox in private kiosk mode
    program = "${pkgs.firefox}/bin/firefox -kiosk -private-window https://hjv.dk";
  };

  # Hardware: Audio and Lid Power Management
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.logind.lidSwitch = "suspend";

  # Declaratively lock down Firefox to prevent filesystem escape
  programs.firefox = {
    enable = true;
    policies = {
      DisableAppUpdate = true;
      DisableDeveloperTools = true;
      DisableFileAccess = true; # Critical: Prevents file:// URI access
      DisableProfileImport = true;
      DisableTelemetry = true;
      DisableSafeMode = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      OverrideFirstRunPage = "";
      PromptForDownloadLocation = false;
      # Disable printing to avoid the print dialog escape vector
      DisablePrinting = true;
      BlockAboutPreferences = true;
      BlockAboutConfig = true;
    };
  };

  # Ensure the system never sleeps or blanks the screen
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
