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
    };
    services.pulseaudio.enable = false;
    my.audio.cleanMic.enable = true;
  };
}
