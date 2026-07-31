{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.ssh-reverse-tunnel;
in {
  options.custom.services.ssh-reverse-tunnel = {
    enable = lib.mkEnableOption "SSH reverse tunnel";
    remoteHost = lib.mkOption {
      type = lib.types.str;
      description = "Remote SSH host for reverse tunnel.";
    };
    remotePort = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "Remote port to forward to.";
    };
    tunnelPort = lib.mkOption {
      type = lib.types.port;
      description = "Local port exposed via reverse tunnel on the remote.";
    };
    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "SSH port of the remote host to connect to.";
    };
    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Remote SSH user for the tunnel connection.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.sshtunnel = {
      isSystemUser = true;
      home = "/var/lib/sshtunnel";
      shell = "${pkgs.shadow}/bin/nologin";
      createHome = true;
      group = "sshtunnel";
    };

    users.groups.sshtunnel = {};

    environment.systemPackages = with pkgs; [autossh];

    systemd.services.ssh-reverse-tunnel = {
      description = "SSH Reverse Tunnel to remote-host";
      after = ["network.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = "sshtunnel";
        WorkingDirectory = "/var/lib/sshtunnel";
        Environment = "AUTOSSH_GATETIME=0";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/lib/sshtunnel/.ssh";
        ExecStart = ''
          ${pkgs.autossh}/bin/autossh \
            -M 0 \
            -N \
            -R ${toString cfg.tunnelPort}:localhost:${toString cfg.remotePort} \
            -i /var/lib/sshtunnel/.ssh/id_ed25519 \
            -p ${toString cfg.sshPort} \
            ${lib.optionalString (cfg.user != null) "-l ${cfg.user}"} \
            -o ServerAliveInterval=60 \
            -o ServerAliveCountMax=3 \
            -o ExitOnForwardFailure=yes \
            -o StrictHostKeyChecking=accept-new \
            -o UserKnownHostsFile=/var/lib/sshtunnel/.ssh/known_hosts \
            ${cfg.remoteHost}
        '';
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
