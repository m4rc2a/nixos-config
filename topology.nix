{
  config,
  ...
}: let
  inherit (config.lib.topology)
    mkInternet
    mkRouter
    mkDevice
    mkConnection
    ;
in {
  nodes.internet = mkInternet {
    connections = [
      (mkConnection "fritzbox" "wan1")
      (mkConnection "wg-router" "wan1")
      (mkConnection "shelog-stratum0" "wan1")
    ];
  };

  # --- Fischernetz (roo6) ---
  nodes.fritzbox = mkRouter "Fritzbox" {
    info = "Fritzbox";
    interfaces = {
      wan1 = {};
      lan1 = {
        network = "home";
        addresses = ["192.168.178.1"];
      };
    };
  };

  networks.home = {
    name = "Fischernetz";
    cidrv4 = "192.168.178.0/24";
  };

  nodes.roo6.interfaces = {
    lan0 = {
      mac = "00:48:54:20:41:3e";
      network = "home";
      addresses = ["192.168.178.190"];
      gateways = ["192.168.178.1"];
    };
    wan0 = {
      mac = "00:48:54:20:41:3d";
      network = "home";
    };
  };

  # --- BunterFunk (WG) ---
  nodes."wg-router" = mkRouter "Router (WG)" {
    interfaces = {
      wan1 = {};
      lan1 = {
        network = "wg";
      };
    };
  };

  networks.wg = {
    name = "BunterFunk";
    cidrv4 = "192.168.1.0/24";
  };

  nodes."marc-desktop".interfaces.eth0 = {
    network = "wg";
    addresses = ["192.168.1.183"];
  };

  nodes."marc-laptop".interfaces.wlan0 = {
    type = "wifi";
    network = "wg";
  };

  # --- SSH-Reverse-Tunnel (roo6 -> shelog.stratum0.org) ---
  nodes."shelog-stratum0" = mkDevice "shelog.stratum0.org" {
    interfaces.wan1 = {};
  };

  nodes.roo6.services.ssh-reverse-tunnel = {
    name = "SSH Reverse Tunnel";
    icon = "services.openssh";
    info = "shelog.stratum0.org:2443 → roo6:22 · shel:8443 → roo6:443";
    details = {
      remote.text = "marc@shelog.stratum0.org";
      forward.text = "-R 2443 → localhost:22 (ssh) · -R 8443 → localhost:443 (caddy web)";
    };
  };
}