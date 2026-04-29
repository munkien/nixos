{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: {
  options.my.desktop = {
    enable = lib.mkEnableOption "activate a desktop manager with audio";
  };
  config = lib.mkIf config.my.desktop.enable {
    environment.systemPackages = [
      (pkgs.stdenvNoCC.mkDerivation {
        name = "tokyo-night-sddm";
        src = inputs.tokyo-night-sddm;
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/share/sddm/themes/tokyo-night-sddm
          cp -r . $out/share/sddm/themes/tokyo-night-sddm/
        '';
      })
    ];

    services.displayManager.sddm = {
      enable = true;
      autoNumlock = true;
      wayland.enable = true;
      theme = "tokyo-night-sddm";
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
          "default.clock.quantum" = 2048;
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 2048;
        };
      };
    };
  };
}
