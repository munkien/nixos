let
  user_munkien = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHBrIzRbUZF4n3SuvZHjzuFv+8vfQrS7Yvov+hjGWJ1";
  users = [user_munkien];

  system_anders_pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHX8xYUGCFSnNC2LfioaQUD1E4QVzLTAcAvlOo7dB110";
  system_server_home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9SkEsdW3iGc/FMDJvfFMmSE60JTbmoT6tGEmVMqfqf";
  systems = [system_anders_pc system_server_home];
in {
  "secret_wifi_env.age".publicKeys = users ++ systems;
  "secret_munkien_password.age".publicKeys = [user_munkien] ++ systems;
}
