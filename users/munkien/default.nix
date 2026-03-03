{config, ...}: {
  age.secrets."munkien_password_hashed".file = ../../secrets/secret_munkien_password.age;

  users.users.munkien = {
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets."munkien_password_hashed".path;
    description = "Anders";
    extraGroups = ["networkmanager" "wheel"];
  };
}
