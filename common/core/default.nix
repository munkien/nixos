{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.disko

    inputs.preservation.nixosModules.preservation
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.quadlet-nix.nixosModules.quadlet
    inputs.arion.nixosModules.arion

    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./ssh.nix
    ./system.nix
    ./tailscale.nix
  ];

  # Global System Settings
  users.users.root.hashedPassword = "$y$jFT$G4A4efQj5fPKiajbtllMI.$0.ejwCo57NJ5Vw0plf9lK9cIp3rVIeqfMKwZeJCDUXD";
  systemd.services.systemd-machine-id-commit.enable = false;
}
