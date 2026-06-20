{
  config,
  pkgs,
  lib,
  ...
}: {
  age.secrets."munkien_password_hashed" = {
    file = ./password.age;
    symlink = false;
    path = "/etc/age-secrets/munkien_password_hashed";
  };

  services.jotta-cli.enable = true;
  programs.fish.enable = true;

  users.users.munkien = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."munkien_password_hashed".path;
    description = "Anders";
    extraGroups = ["networkmanager" "wheel" "podman" "docker"];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [(lib.strings.trim (builtins.readFile ./userPubkey.pub))];
  };

  home-manager.users.munkien = import ./home.nix;
}
