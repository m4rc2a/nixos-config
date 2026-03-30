{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.openssh;
in {
  options.custom.services.openssh = {
    ports = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [22];
      description = "OpenSSH listen ports.";
    };
  };

  config = {
    services.openssh = {
      enable = true;
      ports = cfg.ports;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
      # denyUsers = [ "tmuxwatch" ];
    };

    custom.services.ports.openssh.tcp = cfg.ports;
    custom.services.ports.openssh.udp = [];
  };
}
