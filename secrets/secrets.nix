let
  user_munkien = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHBrIzRbUZF4n3SuvZHjzuFv+8vfQrS7Yvov+hjGWJ1";
  users = [user_munkien];

  system_anders_pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOGQ6tovRRAtmf7oPUt5Jv3yFrJyEJIr97jgwZCv28IE";
  system_server_home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9SkEsdW3iGc/FMDJvfFMmSE60JTbmoT6tGEmVMqfqf";
  systems = [system_anders_pc system_server_home];
in {
  "secret_wifi_24ghz.age".publicKeys = users ++ systems;
  "secret_wifi_5ghz.age".publicKeys = users ++ systems;
  "secret_munkien_password.age".publicKeys = [user_munkien] ++ systems;
}
