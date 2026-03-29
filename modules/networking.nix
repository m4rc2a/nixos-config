{
  lib,
  hostName,
  ...
}: {
  networking = {
    hostName = lib.mkDefault hostName;
    networkmanager.enable = true;

    # firewall zeug
    # # NixOS lädt das Modul "nat-iptables.nix", welches aber
    # # iptables NAT/Forwarding Cleanup Regeln in `networking.firewall.extraCommands` einträgt.
    # # Das ist jedoch nur für das iptables-Backend gedacht und kollidiert mit
    # # backend = "nftables"
    # # extraCommands = lib.mkForce "";
  };
}
