{lib, ...}: {
  # Vi behøver ikke pkgs her længere, da pakkerne er flyttet

  # 1. MergerFS Mount (Dette er OK her, da det er et filsystem)
  fileSystems."/storage" = {
    device = "/mnt/storage1:/mnt/storage2";
    fsType = "fuse.mergerfs";
    options = [
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=mfs"
      "allow_other"
      "nofail"
    ];
  };

  # 2. NeededForBoot Overrides (Kritisk for Impermanence)
  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  # 3. Selve Disko Konfigurationen
  disko.devices = {
    disk = {
      # SYSTEM - NVMe RAID1
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
                extraArgs = ["-f" "-L ROOT"];
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
                extraArgs = ["-f" "-L ROOT"];
              };
            };
          };
        };
      };

      # STORAGE POOL
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
                mountpoint = "/mnt/storage1";
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
                mountpoint = "/mnt/storage2";
                mountOptions = ["compress=zstd:10" "noatime" "commit=120" "nofail"];
              };
            };
          };
        };
      };
    };
  };
}
