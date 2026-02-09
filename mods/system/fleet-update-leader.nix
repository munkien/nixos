{pkgs, ...}: {
  systemd.services.fleet-update-leader = {
    description = "Flake Update Leader: Update, Check, and Push";
    path = with pkgs; [git nix openssh coreutils];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = "/home/munkien/nixos";
    };

    script = ''
      nix flake update --commit-lock-file

      if ! nix flake check --no-build; then
        echo "Check failed! Rolling back lockfile..."
        git restore flake.lock
        exit 1
      fi

      echo "Pushing new lockfile to origin..."
      git push origin master
    '';
  };
  systemd.timers.fleet-update-leader = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "6h";
    };
  };
}
