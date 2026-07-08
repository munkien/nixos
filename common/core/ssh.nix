_: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
      ServerAliveInterval 60
      ServerAliveCountMax 3

      # When munkien connects to GitHub, use the personal read/write key
      Match User munkien Host github.com
        User git
        IdentityFile /home/munkien/.ssh/id_ed25519
        IdentitiesOnly yes

      # When root (Nix Daemon) connects to GitHub, use the system read-only key
      Match User root Host github.com
        User git
        IdentityFile /etc/ssh/ssh_host_ed25519_key
        IdentitiesOnly yes
    '';
    knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  programs.mosh.enable = true;
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 60000;
      to = 61000;
    }
  ];
}
