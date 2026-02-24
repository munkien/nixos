{
  config,
  pkgs,
  lib,
  ...
}: {
  # Naming
  networking.hostName = "pc-anders";

  # Recovery shell
  specialisation = {
    "Recovery-Shell" = {
      configuration = {
        system.nixos.tags = ["recovery"];
        services.getty.autologinUser = "root";
        networking.hostName = lib.mkForce "nixos-recovery";
      };
    };
  };
}
