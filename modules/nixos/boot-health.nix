# Health gate for Automatic Boot Assessment.
#
# Boot counting alone only proves that userspace came up: `boot-complete.target`
# is reached even if networking, the display manager, or the deploy agent are
# broken. That is the case that matters most for a host you cannot walk over to —
# a generation that boots cleanly but has no network can never fetch the fix.
#
# This module inserts checks *before* `boot-complete.target`, so the boot is only
# blessed (and the boot counter cleared) once they pass. If they fail:
#   - the target is not reached, so systemd-bless-boot does not mark the entry
#     good, and the boot counter is left to run down;
#   - after `tries` attempts the generation is treated as bad and systemd-boot
#     falls back to the previous one (see boot.nix).
#
# Dependency direction matters. Per systemd.special(7), units that must succeed
# for a boot to count as successful are ordered before boot-complete.target *and*
# pulled in by it with `Requires=`. A plain `WantedBy=boot-complete.target` would
# NOT be enough: Wants is a weak dependency, so a failing unit would leave the
# target reachable and the generation still blessed. Hence the
# `systemd.targets."boot-complete".requires` below.
#
# Failures are logged to the journal, so a rollback can be explained afterwards.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.healthCheck;

  # Checks are data, so a module that owns a prerequisite can contribute its own
  # check instead of the gate having to know about it. Each check is a shell
  # command that exits 0 when healthy; `message` is what gets logged on failure.
  defaultChecks = [
    {
      name = "default-route";
      # Without a default route the host cannot be reached and cannot pull a fix,
      # which is the failure mode this gate exists for.
      command = "ip route show default | grep -q .";
      message = "no default route";
    }
    {
      name = "comin-active";
      # Without comin the host will not self-update, so a bad generation would
      # never be replaced.
      command = "systemctl is-active --quiet comin.service";
      message = "comin.service is not active";
    }
  ];

  displayManagerCheck = {
    name = "display-manager-active";
    command = "systemctl is-active --quiet display-manager.service";
    message = "display-manager.service is not active";
  };

  # The option is the single source of truth. The display-manager check is part
  # of its default, so appending to the option and reading it back agree.
  inherit (cfg) checks;

  # Rendering lives in lib/ so it can be tested without evaluating a NixOS
  # system; see flake-parts/tests.nix.
  healthChecks = import ../../lib/health-checks.nix {inherit lib;};

  checkScript = pkgs.writeShellApplication {
    name = "fleet-health-check";
    # iproute2 provides `ip`, used by the default-route check. Without it the
    # check cannot run and the gate would fail on every boot.
    runtimeInputs = with pkgs; [coreutils iproute2 systemd];
    text = healthChecks.renderBody checks;
  };
in {
  options.my.healthCheck = {
    enable = lib.mkEnableOption "gate boot-complete.target on fleet health checks";

    checks = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "Short identifier, used in the log line.";
          };
          command = lib.mkOption {
            type = lib.types.str;
            description = "Shell command; exit 0 means healthy.";
          };
          message = lib.mkOption {
            type = lib.types.str;
            description = "What is logged when the check fails.";
          };
        };
      });
      default = defaultChecks ++ lib.optional config.my.desktop.enable displayManagerCheck;
      description = ''
        Prerequisites a boot must satisfy to be blessed. Defaults cover the two
        cases every host has. A module that owns a prerequisite should append its
        own check here rather than editing this module.
      '';
    };

    settleSeconds = lib.mkOption {
      type = lib.types.ints.positive;
      default = 60;
      description = ''
        How long to let the system settle before the checks are evaluated,
        counted from the start of the unit. Network and comin need a moment to
        come up, so evaluating immediately would false-positive.
      '';
    };

    expectDisplayManager = lib.mkOption {
      type = lib.types.bool;
      default = config.my.desktop.enable;
      defaultText = lib.literalExpression "config.my.desktop.enable";
      description = ''
        Whether display-manager.service is expected to be active. Defaults to
        whether this host is graphical.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.fleet-health-check = {
      description = "Fleet health check gating Automatic Boot Assessment";
      # Pulled in by the target (below) and ordered before it, so the checks run
      # as part of the boot transaction that decides blessing.
      before = ["boot-complete.target"];
      wants = ["network-online.target"];
      after = [
        "network-online.target"
        "comin.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Let the system settle before evaluating.
        ExecStartPre = "${pkgs.coreutils}/bin/sleep ${toString cfg.settleSeconds}";
        ExecStart = "${checkScript}/bin/fleet-health-check";
        # A failure must not tear the boot down; it must only withhold the
        # blessing so the boot counter runs down. The unit is left in a failed
        # state (visible in `systemctl status`) rather than retried.
      };
    };

    # Per systemd.special(7): the target must Requires= the units that determine
    # boot success, and be ordered after them.
    systemd.targets."boot-complete".requires = ["fleet-health-check.service"];

    # Make the settings and any rollback-relevant facts inspectable after the
    # fact rather than being a mystery.
    environment.etc."fleet-health-check.conf".text = ''
      # Managed by modules/nixos/boot-health.nix
      settle_seconds=${toString cfg.settleSeconds}
      expect_display_manager=${lib.boolToString cfg.expectDisplayManager}
      boot_counting_tries=${toString config.boot.loader.systemd-boot.bootCounting.tries}
    '';

    # Surface a failed health check in the persisted journal so a rollback can be
    # explained retrospectively.
    preservation.preserveAt."/persist".directories = lib.mkAfter ["/var/log/journal"];
  };
}
