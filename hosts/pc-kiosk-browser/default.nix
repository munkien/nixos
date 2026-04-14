{pkgs, ...}: let
  firefox-kiosk = pkgs.symlinkJoin {
    name = "firefox-kiosk";
    paths = [pkgs.firefox];
    postBuild = ''
      CHROME=$out/lib/firefox/browser/defaults/profile/chrome
      mkdir -p $CHROME
      cat > $CHROME/userChrome.css <<EOF
      .titlebar-buttonbox-container { display: none !important; }
      .titlebar-spacer { display: none !important; }
      EOF

      PREFS=$out/lib/firefox/browser/defaults/profile
      mkdir -p $PREFS
      cat > $PREFS/user.js <<EOF
      user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
      EOF
    '';
  };
in {
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
    program = "${firefox-kiosk}/bin/firefox --private-window https://hjv.dk";
  };

  # Restart Cage (and Firefox) if it ever exits
  systemd.services."cage-tty1" = {
    serviceConfig = {
      Restart = "always";
      RestartSec = 2;
    };
  };

  # Allow printing
  # Enable the CUPS service to print documents.
  networking.firewall.allowedUDPPorts = [161];
  services.printing = {
    enable = true;
    drivers = [pkgs.hplipWithPlugin];
  };
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.hplipWithPlugin];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Allows resolving .local hostnames
    openFirewall = true; # Opens UDP port 5353
  };
  hardware.printers = {
    ensurePrinters = [
      {
        name = "HP_Kiosk_Printer";
        location = "Front Desk";
        deviceUri = "hp:/net/Your_Model_Name?ip=192.168.1.XX"; # Replace with your URI
        model = "drv:///hp/hpcups.drv/hp-officejet_pro_8710.ppd"; # Example PPD
      }
    ];
    ensureDefaultPrinter = "HP_Kiosk_Printer";
  };

  # Hardware: Audio and Lid Power Management
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.logind.settings.Login.HandleLidSwitch = "suspend";

  # Declaratively lock down Firefox to prevent filesystem escape
  programs.firefox = {
    enable = true;
    policies = {
      DisableAppUpdate = true;
      DisableDeveloperTools = true;
      DisableFileAccess = true;
      DisableProfileImport = true;
      DisableTelemetry = true;
      DisableSafeMode = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      TranslateEnabled = false;
      PopupBlocking = {
        Default = false;
        Locked = true;
      };
      OverrideFirstRunPage = "";
      PromptForDownloadLocation = false;
      DisablePrinting = false;
      BlockAboutPreferences = true;
      BlockAboutConfig = true;
      DisplayBookmarksToolbar = "always";
      DisplayMenuBar = "never";
      Homepage = {
        URL = "https://minside.hjv.dk";
        Locked = true;
        StartPage = "homepage-locked";
      };
      Bookmarks = [
        {
          Title = "HJV";
          URL = "https://hjv.dk";
          Favicon = "https://hjv.dk/favicon.ico";
          Placement = "toolbar";
        }
        {
          Title = "Google";
          URL = "https://google.dk";
          Placement = "toolbar";
        }
      ];
      NewTabPage = false;
    };
  };
}
