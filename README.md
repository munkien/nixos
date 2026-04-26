# Munkiens Fleet

A multi-architecture, auto-updating, and highly declarative NixOS configuration repository managing a fleet of workstations, servers, and kiosks.

## 🌟 Key Technologies

- **[NixOS & Flakes](https://nixos.org/)**: The core foundation, using flakes for deterministic inputs and outputs.
- **[Home Manager](https://github.com/nix-community/home-manager)**: Declarative user environment and dotfile management.
- **[Agenix-Rekey](https://github.com/oddlama/agenix-rekey)**: Robust secret management using `age` and YubiKeys. Secrets are securely managed locally and distributed via `rekeyFile` paths.
- **[Impermanence](https://github.com/nix-community/impermanence)**: Systems boot with ephemeral root filesystems (`tmpfs`), explicitly persisting state in `/persist`.
- **[Colmena](https://github.com/zhaofengli/colmena)**: A fast, parallel, and stateless deployment tool to push configurations to the fleet.
- **[Quadlet](https://github.com/SEIAROTg/quadlet-nix)**: Declarative systemd-managed Podman containers (used for services like Frigate, iAlarm).
- **Pre-commit Hooks**: Enforces code quality using `alejandra`, `deadnix`, and `statix`.

## 📁 Repository Structure

```text
.
├── flake.nix        # The core entrypoint defining inputs and outputs
├── hosts/           # Per-machine hardware configurations and overrides
│   ├── pc-anders/
│   ├── server-home-1/
│   └── ...
├── modules/         # Reusable NixOS modules
│   ├── common/      # Base configurations (networking, packages, nix settings)
│   └── services/    # Self-hosted applications (Authelia, Frigate, Caddy, etc.)
├── users/           # User configurations (Home Manager)
│   └── munkien/     # Dotfiles, SSH keys, and application setups
└── secrets/         # Encrypted `.age` secrets managed by agenix-rekey
```

## 🛠️ Usage & Commands

### Updating the Local System
Use the configured `nh` tool to rebuild and apply changes locally:
```bash
nh os switch
```

### Remote Deployments
Deploy to servers or workstations tagged in the flake via Colmena:
```bash
colmena apply
```

### Secret Management
Secrets are managed with `agenix-rekey`. When adding a new secret or a new host, rekey the database:
```bash
agenix rekey
```

## 🚑 Building the Rescue ISO

If you need to generate the custom rescue environment ISO, run the following command. It injects local network configurations into the build environment:

```bash
sudo cat '/run/agenix.d/1/wifi-gl3' > /tmp/wifi-gl3_env && \
nixos-rebuild build-image --image-variant iso --flake .#rescue --impure && \
cp result/iso/*.iso .
```

## 🤖 Note for AI Assistants
- **Modularity**: Modules are designed to be standalone. Service modules typically expose an `enable` flag (e.g. `config.my.services.authelia.enable`).
- **Secrets**: Always use `inputs.self + "/secrets/..."` for `rekeyFile` to ensure paths don't break when modules are imported from different directories.
- **Impermanence**: When creating state directories for services, prefer using systemd's `StateDirectory` combined with `fileSystems` bind mounts from the persist path (e.g., `${config.my.impermanence.persistPath}/services/<name>`) over `tmpfiles.rules` where possible.
- **Packages**: User GUI packages are logically grouped in `users/munkien/apps/*.nix`.