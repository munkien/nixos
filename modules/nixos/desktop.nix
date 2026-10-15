{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.my.desktop;
in {
  # Assumes 'my.desktop.enable' is defined in your centralized options file
  config = lib.mkIf cfg.enable {
    # Required for XWayland compatibility and standard input handling
    services = {
      xserver = {
        enable = true;
        xkb.layout = "dk";
      };
      libinput.enable = true;

      # Display & Desktop Manager
      displayManager.sddm = {
        enable = true;
        autoNumlock = true;
        wayland.enable = true;
        theme = "sugar-dark";
      };

      # Ensure theme is globally available for SDDM to pick up
      desktopManager.plasma6.enable = true;

      # Audio & Multimedia
      printing.enable = true;
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        wireplumber.enable = true;
        # Optimized quantum for responsiveness across the fleet
        extraConfig.pipewire."92-low-latency" = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 1024;
            "default.clock.min-quantum" = 32;
            "default.clock.max-quantum" = 2048;
          };
        };
      };
    };

    environment.systemPackages = [pkgs.sddm-sugar-dark];
    security.rtkit.enable = true;

    # Wayland/Ozone Environment Variables
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
    };
  };
}
