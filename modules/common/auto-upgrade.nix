{
  config,
  lib,
  ...
}: {
  options.my.autoUpgrade = {
    enable = lib.mkEnableOption "automatic NixOS upgrades";
    flake = lib.mkOption {
      type = lib.types.str;
      default = "github:munkien/nixos#${config.networking.hostName}";
    };
    frequency = lib.mkOption {
      type = lib.types.str;
      default = "04:00";
    };
    allowReboot = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf config.my.autoUpgrade.enable {
    system.autoUpgrade = {
      enable = true;
      inherit (config.my.autoUpgrade) flake;
      dates = config.my.autoUpgrade.frequency;
      inherit (config.my.autoUpgrade) allowReboot;
      randomizedDelaySec = "2h";
      runGarbageCollection = true;
    };
    systemd.timers.nixos-upgrade.timerConfig.Persistent = lib.mkForce true;
  };
}
