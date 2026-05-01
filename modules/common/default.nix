{...}: {
  imports = [
    ./boot.nix
    ./auto-upgrade.nix
    ./impermanence.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./ssh.nix
    ./system.nix
    ./tailscale.nix
  ];
}
