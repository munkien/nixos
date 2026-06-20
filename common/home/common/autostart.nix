{
  config,
  lib,
  pkgs,
  ...
}: let
  # Filter list into explicit and auto-calculated delays
  explicitApps = builtins.filter (app: app.delay != null) config.my.autostart;
  autoApps = builtins.filter (app: app.delay == null) config.my.autostart;

  # Build delayed start systemd service configurations
  mkDelayedStart = name: delay: exec: {
    Unit = {
      Description = "${name} Autostart";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep ${toString delay}";
      ExecStart = "${exec}";
      Restart = "on-failure";
    };
    Install = {WantedBy = ["graphical-session.target"];};
  };

  # Auto assign delays sequentially in 5s increments (e.g. 5, 10, 15, 20...)
  autoServices =
    lib.imap0 (index: app: {
      name = lib.strings.toLower app.name;
      value = mkDelayedStart app.name ((index + 1) * 5) app.exec;
    })
    autoApps;

  # Map explicit delay settings
  explicitServices =
    map (app: {
      name = lib.strings.toLower app.name;
      value = mkDelayedStart app.name app.delay app.exec;
    })
    explicitApps;
in {
  options.my = {
    autostart = lib.mkOption {
      default = [];
      description = "List of applications to start automatically on graphical login with sequential delays.";
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Name of the application.";
          };
          exec = lib.mkOption {
            type = lib.types.str;
            description = "Executable command or path to run.";
          };
          delay = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            description = "Start delay in seconds. If null, it is sequentially assigned.";
          };
        };
      });
    };
  };

  config = lib.mkIf (config.my.autostart != []) {
    systemd.user.services = builtins.listToAttrs (autoServices ++ explicitServices);
  };
}
