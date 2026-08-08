{
  lib,
  config,
  ...
}: {
  services.forgejo = {
    enable = true;

    database = {
      type = "sqlite3";
      createDatabase = true;
    };

    settings.server = {
      DOMAIN = "git.zander.cloud";
      ROOT_URL = "https://git.zander.cloud/";
      HTTP_ADDR = "127.0.0.1";
      HTTP_PORT = 3000;
      SSH_PORT = 2222;
    };

    secrets."security"."SECRET_KEY" = lib.mkForce config.sops.secrets."forgejo_session_key".path;
  };

  networking.firewall.allowedTCPPorts = [3000 2222];
}
