# modules/common/impermanence.nix
{
  config,
  lib,
  ...
}: {
  options.my.impermanence = {
    enable = lib.mkEnableOption "impermanence";
    persistPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist";
    };
    extraDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    extraFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = lib.mkIf config.my.impermanence.enable {
    fileSystems.${config.my.impermanence.persistPath}.neededForBoot = true;

    users.mutableUsers = false;

    environment.persistence.${config.my.impermanence.persistPath} = {
      hideMounts = true;

      directories =
        [
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/bluetooth"
          "/etc/adjtime"
          "/etc/ssh"
        ]
        ++ config.my.impermanence.extraDirs;

      files =
        [
          "/etc/machine-id"
        ]
        ++ config.my.impermanence.extraFiles;
    };
  };
}
