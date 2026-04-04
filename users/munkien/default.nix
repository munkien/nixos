{
  config,
  pkgs,
  ...
}: let
  # Absolute path to your user's public key
  munkienPubKey = builtins.readFile (builtins.toPath ./../munkien/secret_key.pub);
in {
  age.secrets."munkien_password_hashed" = {
    file = ./password.age; # relative path, must exist
    symlink = true;
  };

  services.jotta-cli.enable = true;
  programs.fish.enable = true;

  users.users.munkien = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."munkien_password_hashed".path;
    description = "Anders";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.fish;

    # Must be a list of strings
    openssh.authorizedKeys.keys = [munkienPubKey];
  };
}
