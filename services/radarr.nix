{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.radarr;
in {
  options.custom.services.radarr = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 7878;
      description = "Radarr web UI port.";
    };
  };

  config = {
    services.radarr = {
      enable = true;
      openFirewall = false;
      settings = {
        server.port = cfg.port;
      };
    };

    custom.services.ports.radarr.tcp = [cfg.port];
    custom.services.ports.radarr.udp = [];
  };
}
