{lib, pkgs, ...}: {
  /*
  disko.devices = {
    disk = {
      # NVMe 1
      nvme1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_2TB_251124800155"; # <--- RET ID
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "vfat";
                mountpoint = "/boot";
              };
            };

            swap = {
              size = "4G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };

            bcachefs = {
              size = "100%";
              content = {type = "bcachefs";};
            };
          };
        };
      };

      nvme2 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-DIT_NVME2_ID"; # <--- RET ID
        content = {
          type = "gpt";
          partitions = {
            ESP-mirror = {
              size = "1G";
              type = "EF00";
              content = {type = "vfat";};
            };

            # ÆNDRET: 4GB Swap
            swap = {
              size = "4G";
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };

            bcachefs = {
              size = "100%";
              content = {type = "bcachefs";};
            };
          };
        };
      };
      # SATA Diske (Uændret)
      sata1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-DIT_SATA1_ID";
        content = {
          type = "gpt";
          partitions = {
            bcachefs = {
              size = "100%";
              content = {type = "bcachefs";};
            };
          };
        };
      };
      sata2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-DIT_SATA2_ID";
        content = {
          type = "gpt";
          partitions = {
            bcachefs = {
              size = "100%";
              content = {type = "bcachefs";};
            };
          };
        };
      };
      sata3 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-DIT_SATA3_ID";
        content = {
          type = "gpt";
          partitions = {
            bcachefs = {
              size = "100%";
              content = {type = "bcachefs";};
            };
          };
        };
      };
      sata4 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-DIT_SATA4_ID";
        content = {
          type = "gpt";
          partitions = {
            bcachefs = {
              size = "100%";
              content = {type = "bcachefs";};
            };
          };
        };
      };
    };

    bcachefs.main = {
      devices = [
        "ssd:/dev/disk/by-id/nvme-DIT_NVME1_ID-part3"
        "ssd:/dev/disk/by-id/nvme-DIT_NVME2_ID-part3"
        "hdd:/dev/disk/by-id/ata-DIT_SATA1_ID-part1"
        "hdd:/dev/disk/by-id/ata-DIT_SATA2_ID-part1"
        "hdd:/dev/disk/by-id/ata-DIT_SATA3_ID-part1"
        "hdd:/dev/disk/by-id/ata-DIT_SATA4_ID-part1"
      ];
      options = "--metadata_replicas=2 --data_replicas=1 --foreground_target=ssd --metadata_target=ssd --promote_target=ssd --background_target=hdd --errors=ro";
      mountOptions = ["compression=zstd:1" "noatime"];
      subvolumes = {
        "@" = {mountpoint = "/";};
        "@home" = {mountpoint = "/home";};
        "@nix" = {mountpoint = "/nix";};
        "@persist" = {mountpoint = "/persist";};
        "@log" = {mountpoint = "/var/log";};
        "@scratch" = {mountpoint = "/scratch";};
      };
    };
  };

  system.activationScripts.bcachefs-tuning = {
    text = ''
      TOOL=${pkgs.bcachefs-tools}/bin/bcachefs
      echo "Applying Bcachefs Tuning..."

      $TOOL setattr --data_replicas=2 /home
      $TOOL setattr --data_replicas=2 /persist
      $TOOL setattr --metadata_replicas=2 /home
      $TOOL setattr --metadata_replicas=2 /persist
      $TOOL setattr --metadata_replicas=2 /scratch

      # Scratch: Start på HDD (hdd), 1 kopi
      $TOOL setattr --data_replicas=1 /scratch
      $TOOL setattr --foreground_target=hdd /scratch

      mkdir -p /scratch/cache /scratch/steam /scratch/downloads
      chown -R 1000:100 /scratch/steam /scratch/downloads
    '';
  };
  */

  fileSystems."/mnt/bcachefs" = {
    device = "/dev/disk/by-uuid/1185da68-6644-46d3-b0e7-8d0e6cf0ad4f";
    fsType = "bcachefs";
    options = [
      "compression=zstd"
      "foreground_writethrough"
      "noatime"
      "discard"
      "background_target=hdd"
      "foreground_target=ssd"
      "data_replicas=2"
      "metadata_replicas=2"
    ];
  };

  system.activationScripts.bcachefs-tuning = {
    text = ''
      TOOL=${pkgs.bcachefs-tools}/bin/bcachefs
      echo "Applying Bcachefs Tuning..."

      $TOOL set-file-option --data_replicas=1 /scratch
      $TOOL set-file-option --foreground_target=hdd /scratch
    '';
  };

  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;

  disko.devices = {
    disk = {
      # SYSTEM - NVME1
      main = {
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_2TB_251124800155";
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
                };
              };
            };
          };
        };
      };
    };
  };
}
