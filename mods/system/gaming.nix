{pkgs, ...}: {
  environment.sessionVariables = {
    STEAM_DIR = "$HOME/.local/share/Steam";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
      libkrb5
      keyutils
      libpng
      libpulseaudio
      attr
      faudio
      winetricks
    ];
  };

  services.flatpak.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    protonup-qt
    gamescope
    protontricks
  ];
}
