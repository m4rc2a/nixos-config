{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.invidious;
in {
  options.custom.services.invidious = {
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Invidious listen port.";
    };
  };

  config = {
    services.invidious = {
      enable = true;
      port = cfg.port;

      # falls vorhanden im nixos-modul:
      # openFirewall = false;
    };

    custom.services.ports.invidious.tcp = [cfg.port];
    custom.services.ports.invidious.udp = [];
  };
}
