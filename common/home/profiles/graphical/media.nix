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
    ffmpeg-full
    #handbrake: Errors out 12-07-2026
  ];
}
