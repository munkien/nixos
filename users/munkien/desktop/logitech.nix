_: {
  # Create the config file in your user's XDG path
  xdg.configFile."logid.cfg".text = ''
    devices: (
      {
        name: "MX Master 3S";
        smartshift: { on: true; threshold: 20; };
        hiresscroll: { hires: true; invert: false; target: false; };
        dpi: 1500;

        buttons: (
          {
            cid: 0xc3;
            action: {
              type: "Gestures";
              gestures: (
                { direction: "Up"; mode: "OnRelease"; action: { type: "Keypress"; keys: ["KEY_PLAYPAUSE"]; }; },
                { direction: "Down"; mode: "OnRelease"; action: { type: "Keypress"; keys: ["KEY_MUTE"]; }; }
              );
            };
          }
        );
      }
    );
  '';
}
