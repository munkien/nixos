



lock:
  nix-shell https://github.com/vic/flake-file/archive/main.zip -A flake-file.sh --run bootstrap

test:
  git add .
  nh os test

switch:
  nh os switch

update:
  nix flake update
  nix run .#write-flake
  nix flake check

# Re-encrypt secrets for all hosts, then publish for comin to pick up.
# Hosts self-deploy by polling main; see README "Deployment".
deploy:
  agenix rekey -a
  git push

push: 
  nix flake check
  git add .
  git commit -m "just push"
  git push

# Lock UID/GID maps against automatic regeneration
protect-maps:
  sudo chattr +i /var/lib/nixos/uid-map /var/lib/nixos/gid-map

# Unprotect UID/GID maps for deployment
unprotect-maps:
  sudo chattr -i /var/lib/nixos/uid-map /var/lib/nixos/gid-map
