{config, ...}: {
  sops.secrets.munkien_password = {
    neededForUsers = true;
  };

  users.users.munkien = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.munkien_password.path;
    description = "Anders";
    extraGroups = ["networkmanager" "wheel"];
  };
}
