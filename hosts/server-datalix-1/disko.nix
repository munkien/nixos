{lib, ...}:
# KVM VPS — BIOS boot (no UEFI/TPM), 12 GB RAM, 100 GB disk
# Layout:
#   1M    biosboot  GRUB core image (GPT + legacy BIOS requirement)
#   1G    /boot     ext4, persistent — GRUB and kernels live here
#   4G    swap      no hibernate on a VPS, just a safety net
#   55G   /nix      nix store + generations
#   ~39G  /persist  everything you want to survive reboots
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # KVM exposes disks as virtio-blk (/dev/vda) or as /dev/sda.
        # Check with `lsblk` on the live ISO — change if needed.
        device = lib.mkDefault "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            # Required for GRUB on GPT + legacy BIOS
            biosboot = {
              size = "1M";
              type = "EF02";
              priority = 1; # Place first on disk
            };

            # Persistent /boot — GRUB needs real storage, tmpfs won't do
            boot = {
              size = "1G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
                mountOptions = ["defaults" "noatime"];
              };
            };

            swap = {
              size = "4G"; # ~1/3 RAM; no hibernate needed on a VPS
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = false;
              };
            };

            nix = {
              size = "55G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
                mountOptions = ["defaults" "noatime"];
              };
            };

            persist = {
              size = "100%"; # ~39G remaining
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/persist";
                mountOptions = ["defaults" "noatime"];
              };
            };
          };
        };
      };
    };

    # tmpfs root — wiped on every reboot
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=2G" # Plenty for a headless server; uses RAM
          "mode=755"
        ];
      };
    };
  };
}
