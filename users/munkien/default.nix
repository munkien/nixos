{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  age.secrets."munkien_password_hashed" = {
    rekeyFile = ./password.age;
  };

  services.jotta-cli.enable = true;
  programs.fish.enable = true;

  users.users.munkien = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.munkien_password_hashed.path;
    description = "Anders";
    extraGroups = ["networkmanager" "wheel" "podman" "docker"];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [(lib.strings.trim (builtins.readFile ./userkey.pub))];
  };

  home-manager.users.munkien = {
    imports = [
      inputs.plasma-manager.homeModules.plasma-manager
      inputs.nix-flatpak.homeManagerModules.nix-flatpak
      inputs.agenix.homeManagerModules.default
      inputs.agenix-rekey.homeManagerModules.agenix-rekey
      ./home.nix
    ];
  };
}
