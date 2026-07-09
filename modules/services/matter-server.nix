{...}: {
  config = {
    services.matter-server = {
      enable = true;
    };

    custom.services.ports.matter-server.tcp = [5580];
    custom.services.ports.matter-server.udp = [];
  };
}
