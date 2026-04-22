---
name: agenix-rekey-impermanence
description: "Use agenix-rekey for secrets and treat impermanence as an optional feature in NixOS configuration."
applyTo: "**/*.nix"
---

- Secrets must be handled with `age.secrets` / `agenix-rekey` rather than `sops`.
- Do not add `nixpkgs.nixosModules.sops` or use `config.sops` in this repository.
- Prefer `config.age.secrets.<name>.path` or equivalent runtime secrets injection via `age.secrets`.
- `my.impermanence.enable` is optional; do not assume impermanence is enabled by default.
- Persist only when `config.my.impermanence.enable` is true; otherwise keep service state on normal non-impermanent paths.
- Use `config.my.impermanence.persistPath` for the persist root when impermanence is enabled.
