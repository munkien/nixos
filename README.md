# Install - MUST UPDATE
- sudo nix run github:nix-community/disko --extra-experimental-features nix-command --extra-experimental-features flakes -- --mode zap_create_mount ./hosts/workstation/filesystem.nix
- sudo TMPDIR=/mnt/Flake/tmp nixos-install --flake .#workstation


# Build the rescue ISO
- nix run .#build-rescue
