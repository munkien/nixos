{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.munkien = {
    isNormalUser = true;
    initialPassword = "asdfasdf"; # Temporary weak password
    description = "Anders";
    extraGroups = ["networkmanager" "wheel"];
  };
}
