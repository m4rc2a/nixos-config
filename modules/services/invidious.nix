{...}: {
  config = {
    services.invidious = {
      enable = true;
      port = 3001;
      settings.server.http.listen_port = 3001;
    };
    networking.firewall.allowedTCPPorts = [3001];
  };
}
