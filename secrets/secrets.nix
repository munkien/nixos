let
  key = path: builtins.readFile path;

  # Users
  users = {
    munkien = key ../users/munkien/secret_key.pub;
  };

  # Systems
  systems = {
    pc-anders = key ../hosts/pc-anders/secret_key.pub;
    # server-home-1 = key ../hosts/server-home-1/secret_key.pub;
  };

  allSystems = builtins.attrValues systems;
  allUsers = builtins.attrValues users;
in {
  # Shared
  "./common/wifi-gl3_env.age".publicKeys = allUsers ++ allSystems;

  # Users
  "../users/munkien/password.age".publicKeys = [users.munkien] ++ allSystems;

  # Services
  "services/frigate.age".publicKeys = [users.munkien] ++ allSystems;

  # "services/authelia/jwt.age".publicKeys = [ users.munkien systems.server-home ];
}
