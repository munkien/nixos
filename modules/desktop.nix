{
  lib,
  config,
  ...
}: {
  options.my.desktop = {
    enable = lib.mkEnableOption "activate a desktop manager with audio";
  };
  config = lib.mkIf config.my.desktop.enable {
    services.displayManager.sddm = {
      enable = true;
      autoNumlock = true;
    };
    services.desktopManager.plasma6.enable = true;
    services.xserver = {
      enable = true;
      xkb = {
        layout = "dk";
        variant = "";
      };
    };
    services.printing.enable = true;
    services.libinput.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      extraConfig.pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024; # Increase to 2048 if scratches persist
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 2048;
        };
      };
    };
  };
}
