{
  config,
  lib,
  ...
}: {
  options.my.autoUpgrade = {
    enable = lib.mkEnableOption "automatic NixOS upgrades";
    flake = lib.mkOption {
      type = lib.types.str;
      description = "Flake URI to upgrade from, e.g. github:youruser/nixos-config#hostname";
    };
    frequency = lib.mkOption {
      type = lib.types.str;
      default = "04:00";
    };
    allowReboot = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.my.autoUpgrade.enable {
    system.autoUpgrade = {
      enable = true;
      flake = config.my.autoUpgrade.flake;
      dates = config.my.autoUpgrade.frequency;
      allowReboot = config.my.autoUpgrade.allowReboot;
      randomizedDelaySec = "2h"; # stagger updates across hosts
      runGarbageCollection = true;
    };
    systemd.timers.nixos-upgrade.timerConfig.Persistent = lib.mkForce true;
  };
}
