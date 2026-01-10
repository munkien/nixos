{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Absolut nødvendigt for Steam
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    protonup-qt
    gamescope
  ];
}
