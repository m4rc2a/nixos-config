{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.matter-server;
in {
  options.custom.services.matter-server = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 5580;
      description = "matter-server listen port.";
    };
  };

  config = {
    services.matter-server = {
      enable = true;
      port = cfg.port;
    };

    custom.services.ports.matter-server.tcp = [cfg.port];
    custom.services.ports.matter-server.udp = [];
  };
}
