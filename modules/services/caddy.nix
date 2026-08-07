{...}: {
  services.caddy = {
    enable = true;
    virtualHosts."git.zander.cloud" = {
      extraConfig = "reverse_proxy 127.0.0.1:3000";
    };
    virtualHosts."hass.zander.cloud" = {
      extraConfig = "reverse_proxy 127.0.0.1:8123";
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}