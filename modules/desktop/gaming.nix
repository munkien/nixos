{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.gaming;
in {
  options.my.gaming = {
    enable = lib.mkEnableOption "gaming setup (Steam, gamemode, etc.)";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;

      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;

      extraCompatPackages = [
      ];
    };

    services.flatpak.enable = true;

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    environment.systemPackages = with pkgs; [
      protonup-qt
      gamescope
      faudio
      protontricks
    ];
  };
}
