{...}: {
  programs.irssi = {
    enable = true;
    networks = {
      oftc = {
        nick = "munkien";
        server = {
          address = "irc.oftc.net";
          port = 6697;
          autoConnect = true;
        };
        channels = {
          bcache.autoJoin = true;
        };
      };
    };
  };
}
