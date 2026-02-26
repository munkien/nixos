{
  config,
  pkgs,
  lib,
  ...
}: {
  # Structure
  imports = [
    ../common.nix
    ../../mods/system/desktop.nix
    ../../mods/system/secrets.nix
    ../../mods/system/home.nix
    ../../mods/system/wifi-gl3.nix
    ../../mods/system/gaming.nix
  ];

  # Naming
  networking.hostName = "pc-anders";

  # # Recovery shell
  specialisation = {
    "Recovery-Shell" = {
      configuration = {
        system.nixos.tags = ["recovery"];
        services.getty.autologinUser = lib.mkForce "root";
        services.xserver.enable = lib.mkForce false;
        systemd.defaultUnit = lib.mkForce "multi-user.target";
      };
    };
  };
}
