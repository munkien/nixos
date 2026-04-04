{lib, ...}: {
  imports =
    builtins.filter
    (f: f != ./default.nix) # exclude self
    
    (lib.filesystem.listFilesRecursive ./.);
}
