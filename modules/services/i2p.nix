{...}: {
  config = {
    services.i2p.enable = true;
    networking.firewall.allowedTCPPorts = [4444];
  };
}
