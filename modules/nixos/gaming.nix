{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.my.gaming.enable {
  programs = {
    steam = {
      enable = true;

      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;

      extraCompatPackages = [];
    };

    gamemode.enable = true;
    gamescope.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.clr
    ];
  };

  networking.firewall = {
    # Stardew Valley and Satisfactory
    allowedTCPPorts = [
      24642 # Stardew Valley
      7777 # Satisfactory
      8888 # Satisfactory
    ];

    allowedUDPPorts = [
      24642 # Stardew Valley Discovery/Data
      27036 # Steam Remote Play
      7777 # Satisfactory
      8888 # Satisfactory
    ];

    # Steamworks P2P and Voice Chat ranges
    allowedUDPPortRanges = [
      {
        from = 27000;
        to = 27031;
      }
      {
        from = 4380;
        to = 4380;
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    protonup-qt
    faudio
    xwayland-satellite
    protontricks
    steam-run
    dotnet-sdk_8
    icu
    zlib
    openssl
    prelink
  ];
}
