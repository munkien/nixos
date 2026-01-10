{
  lib,
  pkgs,
  ...
}: let
  bcachefs_device = "/dev/disk/by-uuid/fe8de683-7e92-4cc0-ace2-8ce2bccfa296";
  bcachefs_default_options = [
    "noatime"
    "discard"
  ];
in {
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1D9E-C58C";
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
    options = bcachefs_default_options ++ ["subvol=@"];
    neededForBoot = true;
  };
  fileSystems."/var/log" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = bcachefs_default_options ++ ["subvol=@log"];
    neededForBoot = true;
  };
  fileSystems."/scratch" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = bcachefs_default_options ++ ["subvol=@scratch"];
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
  fileSystems."/nix" = {
    device = bcachefs_device;
    fsType = "bcachefs";
    options = bcachefs_default_options ++ ["subvol=@nix"];
    neededForBoot = true;
  };

  system.activationScripts.bcachefs-infrastructure = {
    text = ''
      TOOL=${pkgs.bcachefs-tools}/bin/bcachefs
      POOL="/mnt/bcachefs"

      $TOOL set-file-option --data_replicas=1 /home/munkien/.local/share/Steam

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
