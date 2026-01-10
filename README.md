# Install
- sudo nix run github:nix-community/disko --extra-experimental-features nix-command --extra-experimental-features flakes -- --mode zap_create_mount ./hosts/workstation/filesystem.nix
- sudo TMPDIR=/mnt/Flake/tmp nixos-install --flake .#workstation


# Iso building
- nix build .#nixosConfigurations.installer.config.system.build.isoImage -v
- sudo dd if=$(readlink -f ./result/iso/*.iso) of=/dev/sdXXXXXX bs=4M status=progress conv=fsync
