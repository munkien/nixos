{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wget # system-level fetching
    comma # nix run wrapper, useful system-wide
    rustscan # network tool, useful for any admin
    btop # system monitor
    fastfetch # system info
    ncdu # disk usage
    trippy # network diagnostics
    pwgen # password generation
  ];
}
