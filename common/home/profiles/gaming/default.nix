{
  pkgs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    heroic
    satisfactorymodmanager
    liquidwar
    tbe
    rimsort
  ];

  home.activation.linkSteamDriveC = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn /scratch/battle.net $VERBOSE_ARG ${config.home.homeDirectory}/.local/share/Steam/steamapps/compatdata/2232372708/pfx/drive_c
  '';

  services.flatpak = {
    enable = true;
    uninstallUnused = true;
    update = {
      onActivation = true;
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
      "net.lutris.Lutris"
    ];
  };
}
