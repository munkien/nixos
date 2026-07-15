{
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.comin.nixosModules.comin
  ];

  preservation = {
    preserveAt."/persist" = {
      directories = [
        "/var/lib/comin"
      ];
    };
  };

  services.comin = {
    enable = lib.mkDefault false;
    desktop = {
      enable = config.my.desktop.enable;
      title = "Comin Auto-update";
    };
    remotes = [
      {
        name = "origin";
        url = "https://github.com/munkien/nixos.git";
        branches.main.name = "main";
      }
    ];
  };
}
