{
  config,
  pkgs,
  ...
}: let
  # Absolute path to your user's public key
  munkienPubKey = builtins.readFile ./../munkien/secret_key.pub;
in {
  age.secrets."munkien_password_hashed" = {
    file = ./password.age; # relative path, must exist
    symlink = false;
    path = "/etc/age-secrets/munkien_password_hashed";
  };

  services.jotta-cli.enable = true;
  programs.fish.enable = true;

  # Open ports
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      53317 # LocalSend
      8043 # Omada Web UI
      8088 # Omada HTTP Portal
      8843 # Omada HTTPS Portal
      29811
      29812
      29813
      29814
      29815
      29816 # Omada Management & Discovery
      29817 # Omada Controller Telemetry
    ];

    allowedUDPPorts = [
      53317 # LocalSend
      29810 # Omada Discovery
    ];
  };

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
