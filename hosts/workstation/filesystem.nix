{
  lib,
  pkgs,
  ...
}: let
  bcachefs_device = "/dev/disk/by-uuid/1185da68-6644-46d3-b0e7-8d0e6cf0ad4f";
  bcachefs_default_options = [
    "compression=zstd"
    "foreground_writethrough"
    "noatime"
    "discard"
    "foreground_target=ssd"
    "background_target=hdd"
    "promote_target=ssd"
    "data_replicas=2"
    "metadata_replicas=2"
    "metadata_target=ssd"
    "errors=ro"
  ];
in {
  boot.kernelParams = ["device=UUID=1185da68-6644-46d3-b0e7-8d0e6cf0ad4f"];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/063B-6DAF";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  fileSystems."/mnt/bcachefs" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = bcachefs_default_options;
  };
  fileSystems."/" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = bcachefs_default_options ++ ["subvol=@" "data_replicas=1"];
    neededForBoot = true;
  };
  fileSystems."/var/log" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = bcachefs_default_options ++ ["subvol=@log" "data_replicas=1" "foreground_target=hdd" "promote_target=hdd"];
    neededForBoot = true;
  };
  fileSystems."/scratch" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = bcachefs_default_options ++ ["subvol=@scratch" "data_replicas=1"];
    neededForBoot = true;
  };
  fileSystems."/persist" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = bcachefs_default_options ++ ["subvol=@persist"];
    neededForBoot = true;
  };
  fileSystems."/home" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = bcachefs_default_options ++ ["subvol=@home"];
    neededForBoot = true;
  };
  /*
  fileSystems."/nix" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = bcachefs_default_options ++ ["subvol=@nix" "data_replicas=1"];
    neededForBoot = true;
  };*/
  fileSystems."/nix" = {
    device = "/dev/disk/by-id/nvme-WD_BLACK_SN7100_2TB_251124800155";
    fsType = "btrfs";
    options = ["subvol=@nix" "compress=zstd:1" "noatime" "discard=async" "space_cache=v2"];
    neededForBoot = true;
  };


  system.activationScripts.bcachefs-infrastructure = {
    text = ''
      TOOL=${pkgs.bcachefs-tools}/bin/bcachefs
      POOL="/mnt/bcachefs"
      mkdir -p $POOL

      SUBVOLS="@ @nix @persist @log @home @scratch"

      echo "Checking bcachefs infrastructure on $POOL..."

      for sub in $SUBVOLS; do
        if [ ! -e "$POOL/$sub" ]; then
          echo "Creating missing subvolume: $sub"
          $TOOL subvolume create "$POOL/$sub"
        else
          echo "Subvolume $sub already exists."
        fi
      done
    '';
  };
}
