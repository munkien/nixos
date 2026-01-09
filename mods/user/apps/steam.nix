{
  config,
  pkgs,
  ...
}: {
  home.persistence."/persist" = {
    directories = [
      ".local/share/Steam"
      ".steam"
      ".cache/steam"
    ];
  };
}
