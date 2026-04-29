{pkgs, ...}: {
  home.packages = with pkgs; [
    # Media & Socials
    discord
    spotify
    vlc
    mpv

    # Video editing
    kdePackages.kdenlive
    glaxnimate
    mediainfo
    handbrake
    ffmpeg-full
  ];
}
