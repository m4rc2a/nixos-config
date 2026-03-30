{
  lib,
  config,
  pkgs,
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
    # Selbstsignierte SSL-Zertifikate für interne Dienste generieren
    system.activationScripts.generate-ssl-certs = {
      text = ''
        CERT_DIR="/etc/ssl/certs"
        KEY_DIR="/etc/ssl/private"

        mkdir -p "$CERT_DIR" "$KEY_DIR"

        generate_cert() {
          local domain="$1"
          local cert_file="$CERT_DIR/$domain.crt"
          local key_file="$KEY_DIR/$domain.key"

          if [ ! -f "$cert_file" ] || [ ! -f "$key_file" ]; then
            echo "Generating self-signed certificate for $domain..."
            ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
              -keyout "$key_file" \
              -out "$cert_file" \
              -subj "/CN=$domain"
            chmod 644 "$cert_file"
            chmod 600 "$key_file"
            chown root:root "$cert_file" "$key_file"
          fi
        }

        # Zertifikate für alle internen Dienste
        generate_cert "git.roo6.lan"
      '';
      deps = [];
    };

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
