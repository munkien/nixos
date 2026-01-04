# Install
sudo nix run github:nix-community/disko -- --mode zap_create_mount ./hosts/desktop/filesystem.nix
sudo nixos-install --flake .#desktop
