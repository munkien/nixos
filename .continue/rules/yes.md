# NixOS Project Rules & Guidelines

## General Principles
- **Declarative First:** Every system configuration, package, service, and user setting must be declared via Nix. Avoid imperative commands, manual edits, or GUI configurations.
- **Flakes & Modules:** Use Nix Flakes as the entry point. Structure configurations using modular NixOS modules (`imports`) and flake outputs.
- **Formatting:** Keep all `.nix` files formatted using `alejandra` (or `nixfmt`). Indentation must use spaces, not tabs.

## System Architecture
- **State & Persistence:** Use tools like `disko` for declarative disk partitioning and `preservation` or tmpfs-root patterns for handling persistent storage where applicable.
- **Services:** Implement services via native NixOS options or containerized solutions using Podman Quadlets rather than raw Docker commands.
- **Home Manager:** Manage user environments, dotfiles, and user-level packages declaratively via Home Manager (integrated as a NixOS module or standalone flake).

## Code Style & Anti-Patterns
- **No One-off Commands:** Do not suggest `nix-env -i`, imperative `systemctl` adjustments, or manual file edits inside `/etc` as solutions unless explicitly required for temporary debugging.
- **Explicit Options:** Prefer strongly typed module options over raw strings or unconstrained `mkOption` definitions where possible.
- **Pinning Inputs:** Always lock flake inputs in `flake.lock`. Update inputs intentionally via `nix flake update`.

# Documentation Resources
- [agenix](https://github.com/ryantm/agenix)
- [agenix-rekey](https://github.com/oddlama/agenix-rekey)
- [agenix-shell](https://github.com/aciceri/agenix-shell)
- [antigravity-nix](https://github.com/jacopone/antigravity-nix)
- [arion](https://github.com/hercules-ci/arion)
- [colmena](https://github.com/zhaofengli/colmena)
- [comin](https://github.com/nlewo/comin)
- [disko](https://github.com/nix-community/disko)
- [flake-file](https://github.com/vic/flake-file)
- [flake-parts](https://github.com/hercules-ci/flake-parts)
- [git-hooks.nix](https://github.com/cachix/git-hooks.nix)
- [home-manager](https://github.com/nix-community/home-manager)
- [import-tree](https://github.com/denful/import-tree)
- [nix-auto-follow](https://github.com/fzakaria/nix-auto-follow)
- [nix-flatpak](https://github.com/gmodena/nix-flatpak)
- [nix-index-database](https://github.com/nix-community/nix-index-database)
- [nixos-hardware](https://github.com/NixOS/nixos-hardware)
- [nixpkgs](https://github.com/nixos/nixpkgs)
- [nixvim](https://github.com/nix-community/nixvim)
- [plasma-manager](https://github.com/nix-community/plasma-manager)
- [preservation](https://github.com/WilliButz/preservation)

# External Dependencies
- `github:ryantm/agenix`
- `github:oddlama/agenix-rekey`
- `github:aciceri/agenix-shell`
- `github:jacopone/antigravity-nix`
- `github:hercules-ci/arion`
- `github:zhaofengli/colmena`
- `github:nlewo/comin`
- `github:nix-community/disko`
- `github:vic/flake-file`
- `github:hercules-ci/flake-parts`
- `github:cachix/git-hooks.nix`
- `github:nix-community/home-manager/master`
- `github:denful/import-tree`
- `github:fzakaria/nix-auto-follow`
- `github:gmodena/nix-flatpak`
- `github:nix-community/nix-index-database`
- `github:NixOS/nixos-hardware/master`
- `github:nixos/nixpkgs/nixos-unstable`
- `github:nix-community/nixvim`
- `github:nix-community/plasma-manager`
- `github:WilliButz/preservation`

