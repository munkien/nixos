{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    heroic
    #dwarf-fortress-full
    liquidwar
    tbe
  ];

  home.activation.linkSteamDriveC = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn /scratch/battle.net $VERBOSE_ARG /home/munkien/.local/share/Steam/steamapps/compatdata/2232372708/pfx/drive_c
  '';

  services.flatpak = {
    enable = true;
    uninstallUnused = true;
    update = {
      auto = {
        enable = true;
        onCalendar = "daily";
      };
    };
    packages = [
      "net.openra.OpenRA"
      "com.play0ad.zeroad"
      "com.remnantsoftheprecursors.ROTP"
      "info.beyondallreason.bar"
      "com.revolutionarygamesstudio.ThriveLauncher"
    ];
  };
}
