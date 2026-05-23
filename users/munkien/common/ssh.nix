_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
      "homelab-local" = {
        hostname = "192.168.0.50";
        user = "munkien";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
}
