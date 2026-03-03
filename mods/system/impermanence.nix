{inputs, ...}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  environment.persistence."/persist" = {
    hideMounts = true; #
    directories = [
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/bluetooth"
      "/etc/adjtime"
      "/etc/ssh"
    ];
    files = [
      "/etc/machine-id"
      "/var/lib/sops-nix/key.txt"
    ];

    # users.munkien = {
    #   directories = [
    #     "Downloads"
    #     "Music"
    #     "Pictures"
    #     "Documents"
    #     "Videos"
    #     ".pki"
    #     ".ssh"
    #     ".cache/nix"
    #     ".mozilla" # Firefox profile
    #     ".config" # App settings
    #     ".local/share" # App data
    #     ".local/share/Steam"
    #     ".config/discord"
    #     ".local/state"
    #   ];
    #   files = [
    #     ".bash_history"
    #   ];
    # };
  };

  users.mutableUsers = false;
}
