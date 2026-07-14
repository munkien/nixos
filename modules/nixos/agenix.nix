{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.agenix.nixosModules.default
    inputs.agenix-rekey.nixosModules.default
  ];

  age.rekey = {
    masterIdentities = ["~/.ssh/id_ed25519"];
    storageMode = "local";
    localStorageDir = ../../hosts/${config.networking.hostName}/secrets;
  };

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages.${stdenv.hostPlatform.system}.default
    ssh-to-age
    mkpasswd
  ];

  fileSystems."/persist".neededForBoot = true;

  systemd.services.agenix = {
    requires = ["persist.mount"];
    after = ["persist.mount"];
    wantedBy = ["sysinit.target"];
    unitConfig.DefaultDependencies = false;
  };

  age.identityPaths = [
    "/persist/etc/ssh/ssh_host_ed25519_key"
  ];

  services.openssh.hostKeys = [
    {
      path = "/persist/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
      bits = 4096;
    }
    {
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
}
