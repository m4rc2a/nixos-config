{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;

  # Service-Ports aus config
  services = config.custom.services.ports or {};

  getPorts = svcName: let
    s = services.${svcName} or null;
  in
    if s != null
    then {
      tcp = s.tcp or [];
      udp = s.udp or [];
    }
    else {
      tcp = [];
      udp = [];
    };

  exposedByZone = config.custom.profile.server.exposedByZone or {};

  # Aggregation: pro Zone alle Ports sammeln
  zonePorts =
    lib.mapAttrs
    (
      _zone: svcNames:
        builtins.foldl'
        (acc: svcName: let
          p = getPorts svcName;
        in {
          tcp = acc.tcp ++ p.tcp;
          udp = acc.udp ++ p.udp;
        })
        {
          tcp = [];
          udp = [];
        }
        svcNames
    )
    exposedByZone;

  # Zone -> Interfaces
  zoneIfs = config.custom.firewall.zoneInterfaces or {};

  # Ports zuweisen
  ifacePortAttrs =
    builtins.foldl'
    (
      acc: zone: let
        ifaces = zoneIfs.${zone} or [];
        p =
          zonePorts.${
            zone
          } or {
            tcp = [];
            udp = [];
          };
      in
        acc
        // (builtins.listToAttrs (map (iface: {
            name = iface;
            value = {
              tcp = (acc.${iface}.tcp or []) ++ p.tcp;
              udp = (acc.${iface}.udp or []) ++ p.udp;
            };
          })
          ifaces))
    )
    {}
    (builtins.attrNames zoneIfs);
in {
  options.custom.firewall.zoneInterfaces = mkOption {
    type = types.attrsOf (types.listOf types.str);
    default = {};
    description = "Mapping of firewall zones to network interfaces.";
  };

  config = {
    networking.firewall.enable = true;

    networking.firewall.interfaces =
      lib.mapAttrs (_iface: v: {
        allowedTCPPorts = lib.unique v.tcp;
        allowedUDPPorts = lib.unique v.udp;
      })
      ifacePortAttrs;
  };
}
