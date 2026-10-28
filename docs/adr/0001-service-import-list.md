# ADR-0001: Keep the service import list explicit

**Status:** Accepted
**Date:** 2026-10-28

## Context

An architecture review proposed dissolving the service import list in
`hosts/<name>/default.nix` (14 explicit paths under `common/services/`) into
per-host option flags, so that a host would declare *what it is* rather than
*which files exist*.

The stated motivation was that the list records names but not relationships —
for example, that `mosquitto` backs `zigbee2mqtt`.

## Decision

Keep the import list explicit. Do not convert service modules into
self-enabling modules driven by host option flags.

## Reasons

**The safe direction does not remove the list.** A service module cannot offer
`my.services.<name>.enable` unless it is imported. Host declares a flag, module
reads it — but the import list must still exist for the option to be declared.
This yields two lists that must agree, which is worse than one.

**The unsafe direction recurses.** Making modules infer their enablement from
the state they themselves set is a genuine `infinite recursion encountered`.
Reproduced minimally:

```nix
# A: enables state from an option
modA = {config, ...}: {config.enabled = lib.mkIf config.my.x true;};
# B: infers the option from the state A set
modB = {config, ...}: {config.my.x = config.enabled;};
# evalModules [opts modA modB] => infinite recursion
```

**The relationships claimed do not exist.** `zigbee2mqtt.nix` hardcodes
`mqtt://127.0.0.1:1883`; it does not depend on the `mosquitto` *module*. It
depends on port 1883 being open, which `my.services.mosquitto.ports` already
declares (see ADR-adjacent work in #2). There is no inter-module dependency
graph to encode.

**Six of fourteen service modules have no `enable` flag at all** (`authelia`,
`frigate`, `homeassistant`, `ialarm2mqtt`, `matterjs-server`, `omada`). They
are always-on when imported. Converting them would mean adding a flag to each
before the pattern could apply — pure addition.

## Consequences

- Adding a service to a host is a one-line edit in an explicit, greppable list.
- "Which services does this host run?" is answered by the import list, and
  "how is each one reachable?" by `my.services.*` in the same file.
- Future architecture reviews should not re-propose this refactor. The
  delete test fails: it would move complexity, not concentrate it.

## Alternatives considered

- **Per-service flags + explicit imports** (the safe variant). Rejected: two
  lists that must agree.
- **`import-tree` over `common/services` with per-module guards.** Rejected:
  imports everything on every host, so a service's *code* is present even when
  disabled — and option collisions become possible.
