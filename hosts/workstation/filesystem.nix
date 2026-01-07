{lib, ...}: {
  # 2. NeededForBoot Overrides
  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  disko.devices = {
    disk = {

      # SYSTEM - NVME1
      main = {
        device = "/dev/disk/by-id/XXXXXXXXXXXXX";
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
                    mountOptions = ["compress=zstd:1" "noatime" "discard=async" "space_cache=v2"];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = ["compress=zstd:1" "noatime" "discard=async" "space_cache=v2"];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd:1" "noatime" "discard=async" "space_cache=v2"];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd:1" "noatime" "discard=async" "space_cache=v2"];
                  };
                  "@swap" = {
                    mountpoint = "/.swap";
                    mountOptions = ["compress=no" "noatime" "discard=async" "space_cache=v2"];
                    swap.swapfile.size = "16G";
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = ["compress=zstd:1" "noatime" "discard=async" "space_cache=v2"];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = ["compress=zstd:1" "noatime" "discard=async" "space_cache=v2"];
                  };
                  "@blank" = {};
                };
              };
            };
          };
        };
      };


    };
  };
}
