{ config, pkgs, ... }:

{
  systemd.services.fleet-update-leader = {
    description = "Flake Update Leader: Update, Check, and Push";
    
    # Wait for network availability before attempting to fetch or push
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    path = with pkgs; [ git nix openssh coreutils ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      WorkingDirectory = "/home/munkien/nixos";
      
      # Basic Hardening
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      # Explicitly allow write access to the working directory 
      # (and SSH directory if using root's default SSH keys)
      ReadWritePaths = [ 
        "/home/munkien/nixos" 
        "/root/.ssh" 
      ];
    };

    script = ''
      # Fail fast on any command failure or unbound variables
      set -euo pipefail

      # Define git identity for the automatic commit
      export GIT_AUTHOR_NAME="Fleet Update Leader"
      export GIT_AUTHOR_EMAIL="fleet@localhost"
      export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
      export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

      echo "Updating and committing flake.lock..."
      nix flake update --commit-lock-file

      echo "Checking flake outputs..."
      if ! nix flake check --no-build; then
        echo "Check failed! Reverting the lockfile commit..."
        # Undo the commit made by --commit-lock-file
        git reset --hard HEAD~1
        exit 1
      fi

      echo "Pushing to origin..."
      # Use HEAD to push to the tracked upstream branch dynamically
      git push origin HEAD
    '';
  };

  systemd.timers.fleet-update-leader = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "6h";
    };
  };
}
