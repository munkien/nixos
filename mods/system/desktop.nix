{pkgs, ...}: let
  micName = "CleanMic";
  ladspaPath = "${pkgs.ladspaPlugins}/lib/ladspa";
  rnnoisePath = "${pkgs.rnnoise-plugin}/lib/ladspa";
in {
  environment.systemPackages = with pkgs; [
    rnnoise-plugin
    ladspaPlugins
    pavucontrol
  ];

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.autoNumlock = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;
    xkb = {
      layout = "dk";
      variant = "";
    };
  };

  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.libinput.enable = true;
  programs.noisetorch.enable = true;

  systemd.user.services.noisetorch-autostart = {
    description = "Noisetorch Auto-load";
    after = ["graphical-session.target" "pipewire.service"];
    partOf = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];

    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i";
      RemainAfterExit = true;
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;
      extraConfig = {
        "51-disable-suspicious-inputs" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {"node.description" = "Line In";}
              ];
              actions = {
                update-props = {
                  "node.disabled" = true;
                };
              };
            }
          ];
        };

        # Filter Chain: SteelSeries Clean Mic
        extraConfig.pipewire."10-clean-mic" = {
          "context.modules" = [
            {
              name = "libpipewire-module-filter-chain";
              args = {
                "node.description" = "SteelSeries Clean Mic";
                "media.name" = micName;
                "filter.graph" = {
                  nodes = [
                    # 1. High-pass (Fjerner rumlen)
                    {
                      type = "ladspa";
                      name = "highpass";
                      # BEMÆRK: Absolut sti til filen
                      plugin = "${ladspaPath}/highpass_iir_1890.so";
                      label = "highpass_iir";
                      control = {
                        "Cutoff Frequency" = 100.0;
                        "Stages" = 2.0;
                      };
                    }
                    # 2. EQ (Fixer SteelSeries lyd)
                    {
                      type = "ladspa";
                      name = "eq";
                      plugin = "${ladspaPath}/mbeq_1197.so";
                      label = "mbeq";
                      control = {
                        "low_gain" = -2.0;
                        "low_mid_gain" = 2.0;
                        "mid_gain" = 3.0;
                        "high_mid_gain" = -2.0;
                        "high_gain" = -4.0;
                      };
                    }
                    # 3. RNNoise (Støjreduktion)
                    {
                      type = "ladspa";
                      name = "rnnoise";
                      plugin = "${rnnoisePath}/librnnoise_ladspa.so";
                      label = "noise_suppressor_stereo";
                      control = {"VAD Threshold" = 50.0;};
                    }
                    # 4. Compressor (Jævn lydstyrke)
                    {
                      type = "ladspa";
                      name = "compressor";
                      plugin = "${ladspaPath}/sc4_1882.so";
                      label = "sc4";
                      control = {
                        "RMS/peak" = 0.0;
                        "Attack time (ms)" = 5.0;
                        "Release time (ms)" = 100.0;
                        "Threshold level (dB)" = -20.0;
                        "Ratio (1:n)" = 4.0;
                        "Makeup gain (dB)" = 2.0;
                      };
                    }
                  ];
                };
                "capture.props" = {
                  "node.name" = "capture.clean_mic";
                  "node.passive" = true;
                };
                "playback.props" = {
                  "node.name" = micName;
                  "media.class" = "Audio/Source";
                };
              };
            }
          ];
        };
      };
    };
  };
}
