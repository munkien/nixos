# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./filesystem.nix
    ./hardware.nix

    ../common.nix
    ../../mods/system/desktop.nix
    ../../mods/system/secrets.nix
    ../../mods/system/home.nix
    ../../mods/system/impermanence.nix
    ../../mods/system/gaming.nix

    ../../users/munkien
  ];

  environment.systemPackages = with pkgs; [
    
  ];

  # Style and wallpaper
  stylix = {
    enable = true;
    image = /tmp/current_wallpaper.jpg;

    # https://github.com/tinted-theming/schemes
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono; # Ny syntax i unstable
        name = "JetBrainsMono Nerd Font";
      };
    };

    opacity.terminal = 0.9;
  };
  systemd.user.services.wallpaper-shuffler = {
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "download-walls" ''
        mkdir -p /tmp/wallpapers
        cd /tmp/wallpapers
        ${pkgs.curl}/bin/curl -L -J -O "https://images.unsplash.com/photo-1?auto=format&fit=crop&w=3840&q=80&featured=cyberpunk,tech"
        # Slet gamle filer (bevar de 10 nyeste)
        ls -t | tail -n +11 | xargs rm -f -- 2>/dev/null
        ${pkgs.procps}/bin/pkill -HUP wpaperd || true
      ''}";
    };
    Install.WantedBy = [ "default.target" ]; 
  };

  systemd.user.timers.wallpaper-shuffler = {
    Timer = {
      RandomizedDelaySec = "1h";
      OnUnitActiveSec = "30m";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # Swap Config
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };

  # Btrfs Vedligeholdelse
  services.btrfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = ["/"];
    };
  };

  services.btrbk = {
    ioSchedulingClass = "idle";
    niceness = 19;
    
    instances."local" = {
      onCalendar = "hourly";
      settings = {
        timestamp_format = "long-iso";
        preserve_day_of_week = "monday";
        preserve_hour_of_day = "0";
        snapshot_preserve_min = "6h";
        snapshot_preserve = "24h 7d 4w";

        volume."/persist" = {
          snapshot_dir = "/.snapshots/persist";
          subvolume = ".";
        };
      };
    };
  };
  
  systemd.tmpfiles.rules = [
    "d /.snapshots/persist 0700 root root -"
  ];

  networking.hostName = "workstation";
}
