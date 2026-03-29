{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.gitea;
in {
  options.custom.services.gitea = {
    httpPort = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "Gitea HTTP listen port.";
    };
  };

  config = {
    services.gitea = {
      enable = true;
      database.type = "sqlite3";

      appName = "Fischerwerft";

      settings = {
        "ui.meta" = {
          AUTHOR = "Fischernetz / Fischerwerft";
          DESCRIPTION = "Interner Git-Dienst im Fischernetz (Gitea).";
          KEYWORDS = "git,gitea,self-hosted,fischernetz,fischerwerft";
        };
        server = {
          HTTP_PORT = cfg.httpPort;
          SSH_PORT = 22;

          DOMAIN = "git.roo6.lan";
          ROOT_URL = "https://git.roo6.lan";

          DISABLE_SSH = false;
          START_SSH_SERVER = false; # OpenSSH übernimmt
          ENABLE_SSH_KEY_LOOKUP = true;
        };

        action.ENABLED = true;
      };
    };

    # Firewall-Ports: nur das, was Gitea wirklich selbst öffnet
    custom.services.ports.gitea.tcp = [cfg.httpPort];
    custom.services.ports.gitea.udp = [];
  };
}
