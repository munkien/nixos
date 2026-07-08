{config, ...}: {
  age.rekey = {
    masterIdentities = ["~/.ssh/id_ed25519"];
    storageMode = "local";
    localStorageDir = ../../hosts/${config.networking.hostName}/secrets;
  };
}
