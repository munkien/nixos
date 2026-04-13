_: {
  services.ntopng = {
    enable = true;
    interfaces = ["view:collector:2055"];
  };
  networking.firewall.allowedTCPPorts = [3000]; # Web UI
  networking.firewall.allowedUDPPorts = [2055]; # NetFlow Collector
}
