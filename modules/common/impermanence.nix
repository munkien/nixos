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
      description = "Path used for persistent storage when impermanence is enabled.";
    };
    extraDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional directories that should be made persistent under the impermanence root.";
    };
    extraFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional files that should be made persistent under the impermanence root.";
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
