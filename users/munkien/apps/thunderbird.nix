{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.thunderbird = {
    enable = true;
    profiles.munkien = {
      isDefault = true;
      settings = {
        "calendar.timezone.useSystemTimezone" = true;
        "calendar.timezone.local" = "Europe/Copenhagen";
        "intl.regional_prefs.use_os_locales" = true;
      };
    };
  };
  home.file.".thunderbird/munkien/feeds.json".text = builtins.toJSON [
    {
      url = "https://nixos.org/blogs.xml";
      title = "NixOS Blog";
    }
    {
      url = "https://news.ycombinator.com/rss";
      title = "Hacker News";
    }
  ];
}
