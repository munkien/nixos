# Install
- sudo nix run github:nix-community/disko --extra-experimental-features nix-command --extra-experimental-features flakes -- --mode zap_create_mount ./hosts/desktop/filesystem.nix
- sudo TMPDIR=/mnt/Flake/tmp nixos-install --flake .#desktop
- sudo btrfs subvolume delete /mnt/@blank
- sudo btrfs subvolume snapshot /mnt /mnt/@blank
- sudo find /mnt/@blank -mindepth 1 -delete
