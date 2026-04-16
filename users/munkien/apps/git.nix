_: {
  services.ssh-agent.enable = true;

  programs.git = {
    enable = true;
    settings = {
      url."git@github.com:".insteadOf = "https://github.com/";
      user = {
        name = "munkien";
        email = "munkien@gmail.com";
      };
      init = {
        defaultBranch = "master";
      };
      pull = {
        rebase = true;
      };
      core.editor = "nano";
      push.autoSetupRemote = "true";
    };
  };
}
