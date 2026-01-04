# Install
sudo nix run github:nix-community/disko --extra-experimental-features nix-command --extra-experimental-features flakes -- --mode zap_create_mount ./hosts/desktop/filesystem.nix
sudo nixos-install --flake .#desktop
