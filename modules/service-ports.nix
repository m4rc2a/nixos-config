{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options.custom.services.ports = mkOption {
    type = types.attrsOf (types.submodule ({...}: {
      options = {
        tcp = mkOption {
          type = types.listOf types.port;
          default = [];
        };
        udp = mkOption {
          type = types.listOf types.port;
          default = [];
        };
      };
    }));
    default = {};
  };
}
