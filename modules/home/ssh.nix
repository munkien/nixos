_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    startAgent = true;

    settings = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };
}
