# Todo

Kept short deliberately. Items are removed when done rather than ticked, and
anything not tied to a real symptom is dropped — an stale TODO costs more than
an empty one, because it sends the next reader at files that no longer exist.

## Open

- **matterjs-server exposure is undeclared.** It runs with
  `network_mode = "host"` and opens no firewall ports. Matter commissioning
  normally needs 5540 (TCP+UDP) and mDNS 5353, but this was not verified against
  the container, so nothing was changed. Decide whether it should be reachable,
  then declare it under `my.services` like the others.

- **`my.services` vs `openFirewall`.** `caddy` and `glances` set
  `openFirewall = true` in their nixpkgs modules and therefore own their ports
  outside `my.services`. That is recorded in `hosts/server-home-1/default.nix`,
  but if the split ever causes confusion, pin the ports explicitly there and
  turn `openFirewall` off.

- **Secrets.** `agenix-rekey` is workable but the ergonomics are rough (`just
  deploy` rekeys everything). A secrets manager (Vault, SOPS, or agenix with
  fewer moving parts) was considered and remains unstarted. Not urgent — the
  current setup works and is documented.

## Recently resolved

- Service exposure centralised in `my.services` (firewall + Caddy vhosts).
- Host inventory derived from `hosts/`; `tags` removed.
- Option modules merged into `modules/nixos/profile.nix`.
- Frigate settings are attrsets, rendered to YAML, bind-mounted read-only.
- Health-gate checks are a contributor list (`my.healthCheck.checks`).
- Frigate and Authelia configs bind-mount from the store instead of being
  copied by an activation script, so they converge on switch.
- `nil` removed (`nixd` is the configured language server).
- `pods` and `podman-desktop` removed (podman is used from the CLI).
- `wl-clipboard` declared once.

## Rejected, with reasons

- **Dissolving the service import list.** See
  `docs/adr/0001-service-import-list.md` — the self-enabling variant needs the
  module imported for its option to exist (two lists that must agree), and the
  inferring variant is an infinite recursion.
