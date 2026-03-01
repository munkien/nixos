{inputs, ...}: {
  imports = [inputs.impermanence.nixosModules.impermanence];

  sops.age.sshKeyPaths = ["/persist/etc/ssh/ssh_host_ed25519_key"];

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

    users.munkien = {
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        ".mozilla" # Firefox profile
        ".config" # App settings
        ".local/share" # App data
      ];
      files = [
        ".bash_history"
      ];
    };
  };

  boot.tmp.useTmpfs = true;
  users.mutableUsers = false;
}
