



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

deploy:
  agenix rekey -a
  colmena apply

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
