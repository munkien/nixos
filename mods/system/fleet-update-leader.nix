{
  pkgs,
  ...
}: {
  systemd.services.fleet-update-leader = {
    description = "Flake Update Leader: Update, Check, and Push";
    path = with pkgs; [git nix openssh coreutils];

    serviceConfig = {
      Type = "oneshot";
      User = "munkien";
      WorkingDirectory = "/home/munkien/nixos";
    };

    script = ''
      # 1. Update the lockfile with a standard summary message
      # This handles multiple updates by listing them all in the commit
      nix flake update --commit-lock-file --commit-lockfile-summary

      # 2. The Safety Check (The most important step)
      # We only push if the flake is actually valid/buildable
      echo "Running safety check..."
      if ! nix flake check --no-build; then
        echo "Check failed! Rolling back lockfile..."
        git checkout flake.lock
        exit 1
      fi

      # 3. Push to the repository so followers can see it
      echo "Pushing new lockfile to origin..."
      git push origin main
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
