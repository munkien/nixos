{
  config,
  lib,
  pkgs,
  ...
}: {
  services.smartd = lib.mkIf (!config.virtualisation.hypervGuest.enable) {
    enable = true;
    # Native scheduling:
    # (S)hort test: daily at 02:00
    # (L)ong test: weekly on Saturday at 03:00
    defaults.autodetected = "-a -o on -S on -n standby,q -s (S/../.././02|L/../../6/03)";

    # Native Alerting:
    # -m root sends an email to the local root user (which you can alias in your mail setup)
    # -M exec sends an alert to a specific script if you want custom logic
    notifications = {
      mail.enable = true;
      mail.recipient = "root"; # You can point this to your actual email if configured
      wall.enable = true;
    };
  };
}
