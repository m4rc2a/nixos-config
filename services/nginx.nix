{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.nginx;
in {
  options.custom.services.nginx = {
    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 80;
      description = "nginx HTTP port";
    };
    httpsPort = lib.mkOption {
      type = lib.types.port;
      default = 443;
      description = "nginx HTTPS port";
    };
  };

  config = {
    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      # optional, aber sauber, falls du Ports jemals ändern willst:
      # (nginx unterstützt das grundsätzlich)
      # defaultHTTPListenPort = cfg.httpPort;
      # defaultSSLListenPort = cfg.httpsPort;

      virtualHosts."git.roo6.lan" = {
        forceSSL = true;
        sslCertificate = "/etc/ssl/certs/git.roo6.lan.crt";
        sslCertificateKey = "/etc/ssl/private/git.roo6.lan.key";
        locations."/" = {
          proxyPass = "http://127.0.0.1:3001";
          proxyWebsockets = true; # für viele Apps hilfreich
        };
      };
    };

    custom.services.ports.nginx.tcp = [cfg.httpPort cfg.httpsPort];
    custom.services.ports.nginx.udp = [];
  };
}
