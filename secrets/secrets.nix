let
  user_munkien = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHBrIzRbUZF4n3SuvZHjzuFv+8vfQrS7Yvov+hjGWJ1";
  users = [user_munkien];
  system_anders_pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHX8xYUGCFSnNC2LfioaQUD1E4QVzLTAcAvlOo7dB110";
  system_server_home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDBLOn8WFpEJa9SQG7BplBP3dZo00kXTJ2gaailooqeb";
  systems = [system_anders_pc system_server_home];
in {
  "common/wifi_env.age".publicKeys = users ++ systems;
  "secret_munkien_password.age".publicKeys = [user_munkien] ++ systems;
  "secret_service_password.age".publicKeys = [user_munkien] ++ systems;
  "AUTHELIA_JWT_SECRET.age".publicKeys = [user_munkien system_server_home];
  "AUTHELIA_SESSION_SECRET.age".publicKeys = [user_munkien system_server_home];
  "AUTHELIA_STORAGE_ENCRYPTION_KEY.age".publicKeys = [user_munkien system_server_home];
  "acme_env.age".publicKeys = [user_munkien system_server_home];
}
