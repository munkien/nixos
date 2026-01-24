{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    quickemu
  ];
  home.sessionVariables = {
    QUICKEMU_VMDIR = "/scratch/quickemu";
  };
}
