{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.agenix.homeManagerModules.default
    inputs.agenix-rekey.homeManagerModules.agenix-rekey
  ];

  age.rekey = {
    masterIdentities = ["~/.ssh/id_ed25519"];
    storageMode = "local";
    localStorageDir = ../../users/${config.home.username}/secrets;
    hostPubkey = ../../users/${config.home.username}/userkey.pub;
  };
  systemd.user.tmpfiles.rules = [
    "d %h/secrets 0700 - - - -"
  ];
}
