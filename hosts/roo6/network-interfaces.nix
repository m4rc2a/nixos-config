{...}: {
  imports = [
    ../../modules/firewall.nix
    ../../modules/service-ports.nix
  ];
  systemd.network.links = {
    "10-wan0" = {
      matchConfig.MACAddress = "00:48:54:20:41:3d";
      linkConfig.Name = "wan0";
    };

    "10-lan0" = {
      matchConfig.MACAddress = "00:48:54:20:41:3e";
      linkConfig.Name = "lan0";
    };
  };

  custom.firewall.zoneInterfaces = {
    wan = ["wan0"];
    lan = ["lan0"];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 0;
    "net.ipv6.conf.all.forwarding" = 0;
  };
}
