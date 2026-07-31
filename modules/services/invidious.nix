{...}: {
  config = {
    services.invidious = {
      enable = true;
    };
    networking.firewall.allowedTCPPorts = [3000];
  };
}
