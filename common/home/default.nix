{
  lib,
  osConfig,
  ...
}: {
  imports =
    [./common]
    ++ lib.optionals osConfig.my.gaming.enable [./profiles/gaming];
}
