



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
  nix run .#write-flake
  nh os build
  nix flake check

push: 
  nix flake check
  git add .
  git commit -m "just push"
  git push

