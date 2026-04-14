# Install - MUST UPDATE
- 

# Build the rescue ISO
sudo cat '/run/agenix.d/1/wifi-gl3' > /tmp/wifi-gl3_env && \
nixos-rebuild build-image --image-variant iso --flake .#rescue --impure && \
cp result/iso/*.iso .