{pkgs, ...}: {
  time.timeZone = "Europe/Copenhagen";
  console.keyMap = "dk-latin1";

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocales = ["da_DK.UTF-8/UTF-8" "en_DK.UTF-8/UTF-8"];
    extraLocaleSettings = {
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
  };

  services.timesyncd.enable = false;
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
  networking.firewall.allowedUDPPorts = [123];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      fira-code
      fira-code-symbols
      nerd-fonts.fira-code
    ];

    # Optional: Set the absolute fallback fonts if a specific app ignores KDE's rules
    fontconfig.defaultFonts = {
      serif = ["Noto Serif"];
      sansSerif = ["Noto Sans"];
      monospace = ["FiraCode Nerd Font"];
    };
  };
}
