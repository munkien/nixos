_: {
  imports = [
    ./developer.nix
    ./firefox.nix
    ./logitech.nix
    ./irssi.nix
    ./media.nix
    ./plasma.nix
    ./quickemu.nix
    ./thunderbird.nix
  ];

  programs.nixvim = {
    enable = true;
    imports = [./nixvim.nix];
  };
}
