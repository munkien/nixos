_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
    };
    settings = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };

  services.ssh-agent = {
    enable = true;
    # Set default lifetime to 1 hour (3600 seconds)
    defaultMaximumIdentityLifetime = 3600;
  };
}
