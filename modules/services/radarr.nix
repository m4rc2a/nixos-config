{...}: {
  config = {
    services.radarr = {
      enable = true;
      openFirewall = false;
    };

    custom.services.ports.radarr.tcp = [7878];
    custom.services.ports.radarr.udp = [];
  };
}
