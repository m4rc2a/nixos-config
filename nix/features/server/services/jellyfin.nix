{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.jellyfin;
in {
  options.custom.services.jellyfin = {
    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 8096;
      description = "Jellyfin HTTP port";
    };
    httpsPort = lib.mkOption {
      type = lib.types.port;
      default = 8920;
      description = "Jellyfin HTTPS port";
    };
  };

  config = {
    services.jellyfin = {
      enable = true;
      dataDir = "/var/lib/jellyfin";
      openFirewall = false;
    };

    custom.services.ports.jellyfin.tcp = [cfg.httpPort cfg.httpsPort];
    custom.services.ports.jellyfin.udp = [];
  };
}
