{...}: {
  config = {
    services.i2p.enable = true;

    custom.services.ports.i2p.tcp = [4444];
    custom.services.ports.i2p.udp = [];
  };
}
