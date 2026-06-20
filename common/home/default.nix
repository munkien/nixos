{
  lib,
  osConfig,
  ...
}: {
  imports =
    [./common]
    ++ lib.optionals osConfig.my.graphical.enable [./profiles/graphical]
    ++ lib.optionals osConfig.my.gaming.enable [./profiles/gaming];
}
