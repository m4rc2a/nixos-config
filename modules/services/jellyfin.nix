{...}: {
  config = {
    services.jellyfin = {
      enable = true;
      dataDir = "/var/lib/jellyfin";
      openFirewall = false;
    };

    custom.services.ports.jellyfin.tcp = [8096 8920];
    custom.services.ports.jellyfin.udp = [];
  };
}
