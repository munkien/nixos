# Rendering of health-gate checks, kept separate from the module so it can be
# tested without evaluating a whole NixOS system (doing so inside flake-parts
# recurses, because the test would reference the flake it is part of).
#
# A check is { name, command, message }. `command` is a shell command that exits
# 0 when healthy.
{lib}: let
  # One check block. `report` and `failures` come from the enclosing script.
  renderCheck = check: ''
    # ${check.name}
    if ${check.command} 2>/dev/null; then
      printf 'ok: ${check.name}\n'
    else
      report "FAIL: ${check.message}"
      failures=$((failures + 1))
    fi
  '';
in {
  inherit renderCheck;

  # The whole script body: one block per check, then the verdict.
  renderBody = checks: ''
    set -uo pipefail

    failures=0

    report() {
      printf 'fleet-health-check: %s\n' "$1" >&2
      logger -t fleet-health-check -p daemon.err -- "$1" || true
    }

    ${lib.concatMapStringsSep "\n" renderCheck checks}

    if [ "$failures" -eq 0 ]; then
      printf 'fleet-health-check: all checks passed\n'
      exit 0
    fi

    report "$failures check(s) failed; withholding boot blessing so the generation can be rolled back"
    exit 1
  '';
}
