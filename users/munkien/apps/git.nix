{
  config,
  pkgs,
  inputs,
  ...
}: {
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
      core.sshCommand = "ssh -i ~/.ssh/id_ed25519 -F /dev/null";
      push.autoSetupRemote = "true";
    };
  };
}
