{
  config,
  pkgs,
  inputs,
  ...
}: {
  # System-level identity
  users.users.munkien = {
    isNormalUser = true;
    description = "Anders Munk";
    extraGroups = ["networkmanager" "wheel" "podman"];
  };

  # User-level environment
  home-manager.users.munkien = {pkgs, ...}: {
    home.stateVersion = "26.05";

    programs.git = {
      enable = true;
      userName = "Anders Munk";
      # userEmail = "anders@example.com";
    };

    # You can split this further later (e.g., imports = [ ./plasma.nix ./cli.nix ];)
  };
}
