{lib, ...}: {
  options.my = {
    profiles.desktop.enable = lib.mkEnableOption "Desktop environment and GUI apps";
    profiles.gaming.enable = lib.mkEnableOption "Gaming optimizations and tools";
    profiles.developer.enable = lib.mkEnableOption "Developer tools and utilities";
    profiles.containers.enable = lib.mkEnableOption "Containerization tools and runtimes";
  };
}
