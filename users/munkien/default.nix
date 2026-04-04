{
  config,
  pkgs,
  ...
}: {
  age.secrets."munkien_password_hashed" = {
    file = ../../secrets/secret_munkien_password.age;
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHBrIzRbUZF4n3SuvZHjzuFv+8vfQrS7Yvov+hjGWJ1 munkien@gmail.com"
    ];
  };
}
