{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  fileSystems."/storage" = {
    device = "/mnt/storage1:/mnt/storage2";
    fsType = "fuse.mergerfs";
    options = [
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=mfs" # Most Free Space - god til dine SMR diske
      "allow_other"
      "nofail"
    ];
  };

  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
    snapraid
  ];

  zramSwap = {
    enable = true;
    memoryPercent = 50;
    priority = 100;
  };
  swapDevices = [
    {
      device = "/.swap/swapfile";
      size = 8192;
      priority = 0;
    }
  ];

  services.btrfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = ["/"];
    };
  };

  # Snapper!
  services.snapper = {
    configs = {
      persist = {
        SUBVOLUME = "/persist";
        ALLOW_USERS = ["munkien"];
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        TIMELINE_LIMIT_HOURLY = "10";
        TIMELINE_LIMIT_DAILY = "7";
        TIMELINE_LIMIT_WEEKLY = "0";
        TIMELINE_LIMIT_MONTHLY = "0";
        TIMELINE_LIMIT_YEARLY = "0";
      };
    };
  };

  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  disko.devices = {
    disk = {
      #################################################################
      # SYSTEM - NVMe RAID1 (sdb og sdd)
      #################################################################
      main = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = ["-n" "BOOT"];
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f" "-L ROOT" "-d raid1" "-m raid1"];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd:10" "noatime" "commit=120"];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd:10" "noatime" "commit=120"];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd:10" "noatime" "commit=120"];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd:10" "noatime" "commit=120"];
                  };
                  "@swap" = {
                    mountpoint = "/.swap";
                    swap.swapfile.size = "16G";
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = ["compress=zstd:10" "noatime" "commit=120"];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = ["compress=zstd:10" "noatime" "commit=120"];
                  };
                  "@blank" = {};
                };
              };
            };
          };
        };
      };

      nvme2 = {
        device = "/dev/sdd";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = ["-n" "BOOT_B"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f" "-L ROOT" "-d raid1" "-m raid1"]; # Samme label og profil
              };
            };
          };
        };
      };

      #################################################################
      # STORAGE POOL - Individuelle diske (bedst til SMR)
      #################################################################
      storage1 = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions.data = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f" "-L STORAGE1" "-d single" "-m dup"];
              subvolumes."@storage" = {
                mountpoint = "/mnt/storage1"; # Unikt mountpoint per disk
                mountOptions = ["compress=zstd:10" "noatime" "commit=120" "nofail"];
              };
            };
          };
        };
      };

      storage2 = {
        device = "/dev/sdc";
        type = "disk";
        content = {
          type = "gpt";
          partitions.data = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f" "-L STORAGE2" "-d single" "-m dup"];
              subvolumes."@storage" = {
                mountpoint = "/mnt/storage2"; # Unikt mountpoint per disk
                mountOptions = ["compress=zstd:10" "noatime" "commit=120" "nofail"];
              };
            };
          };
        };
      };
    };
  };
}
