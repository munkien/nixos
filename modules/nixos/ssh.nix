{lib, ...}: {
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

  # System-wide SSH client configuration
  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      ServerAliveInterval 60
      ServerAliveCountMax 3

      # Automation Identity
      Match User root Host github.com
        User git
        IdentityFile /persist/etc/ssh/ssh_host_ed25519_key
        IdentitiesOnly yes
    '';
    knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };

  # Enable Mosh for high-latency/mobile links
  programs.mosh.enable = true;
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 60000;
      to = 61000;
    }
  ];
}
