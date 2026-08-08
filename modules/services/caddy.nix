{
  networking.firewall.allowedTCPPorts = [80 443];

  services.caddy = {
    enable = true;
    virtualHosts = {
      "git.zander.cloud" = {
        extraConfig = "tls internal\nreverse_proxy 127.0.0.1:3000";
      };
      "hass.zander.cloud" = {
        extraConfig = "tls internal\nreverse_proxy 127.0.0.1:8123";
      };
      "jellyfin.zander.cloud" = {
        extraConfig = "tls internal\nreverse_proxy 127.0.0.1:8096";
      };
      "invidious.zander.cloud" = {
        extraConfig = "tls internal\nreverse_proxy 127.0.0.1:3001";
      };
      "radarr.zander.cloud" = {
        extraConfig = "tls internal\nreverse_proxy 127.0.0.1:7878";
      };
    };
  };
}