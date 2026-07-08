{config, ...}: {
  system.autoUpgrade = {
    enable = true;
    flake = "github:munkien/nixos#${config.networking.hostName}";
    dates = "04:00";
  };
  systemd.timers.nixos-upgrade.timerConfig.Persistent = true;
}
