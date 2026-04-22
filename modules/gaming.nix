{
  config,
  lib,
  pkgs,
  ...
}: {
  options.my.gaming = {
    enable = lib.mkEnableOption "gaming setup (Steam, gamemode, etc.)";
  };

  config = lib.mkIf config.my.gaming.enable {
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
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
        rocmPackages.clr
      ];
    };

    networking.firewall = {
      # Port 24642 is the default for Stardew Valley multiplayer
      allowedTCPPorts = [24642];
      allowedUDPPorts = [
        24642 # Stardew Valley Discovery/Data
        27036 # Steam Remote Play
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

    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    environment.systemPackages = with pkgs; [
      protonup-qt
      faudio
      protontricks
      steam-run
      dotnet-sdk_8
      icu
      zlib
      openssl
      prelink
    ];
  };
}
