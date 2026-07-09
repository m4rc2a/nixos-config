{...}: {
  config = {
    services.invidious = {
      enable = true;
    };

    custom.services.ports.invidious.tcp = [3000];
    custom.services.ports.invidious.udp = [];
  };
}
