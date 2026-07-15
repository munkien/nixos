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

  preservation.preserveAt."/persist" = {
    directories = [
      {
        directory = "/home/munkien/nixos";
        user = "munkien";
        group = "users";
      }
      {
        directory = "/home/munkien/.ssh";
        user = "munkien";
        group = "users";
        mode = "0700";
      }
    ];
  };

  home-manager.users.munkien.imports = [./home.nix];
}
