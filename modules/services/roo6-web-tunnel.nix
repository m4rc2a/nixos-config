{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.roo6-web-tunnel;
in {
  options.custom.services.roo6-web-tunnel = {
    enable = lib.mkEnableOption "Persistent SSH LocalForward tunnel to roo6 web services via shelog";

    remoteHost = lib.mkOption {
      type = lib.types.str;
      default = "shelog.stratum0.org";
      description = "SSH relay host (shelog) that exposes the reverse-forwarded roo6 port.";
    };
    remotePort = lib.mkOption {
      type = lib.types.port;
      default = 20022;
      description = "SSH port of the relay host.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "marc";
      description = "SSH user on the relay host.";
    };
    identityFile = lib.mkOption {
      type = lib.types.path;
      description = "SSH identity for the tunnel connection.";
    };
    bindPort = lib.mkOption {
      type = lib.types.port;
      default = 443;
      description = "Local port to expose (HTTPS default; services resolve to 127.0.0.1).";
    };
    remoteForwardPort = lib.mkOption {
      type = lib.types.port;
      default = 8443;
      description = "Reverse-forwarded port on the relay that reaches roo6:443.";
    };
    tunnelUser = lib.mkOption {
      type = lib.types.str;
      default = "marc";
      description = "System user the SSH client runs as (needs read access to identityFile and ~/.ssh/known_hosts).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Trust Caddy's internal CA so *.zander.cloud resolves TLS over the tunnel.
    security.pki.certificateFiles = [../certs/caddy-roo6-root.crt];

    systemd.services.roo6-web-tunnel = {
      description = "SSH LocalForward tunnel to roo6 web (relay:${toString cfg.remoteForwardPort} → local:${toString cfg.bindPort})";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = cfg.tunnelUser;
        # Allow binding the privileged HTTPS port 443 as a non-root user.
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.openssh}/bin/ssh"
          "-F /dev/null" # ignore ~/.ssh/config (ControlMaster, agent) for a clean tunnel
          "-N"
          "-o ServerAliveInterval=60"
          "-o ServerAliveCountMax=3"
          "-o ExitOnForwardFailure=yes"
          "-o StrictHostKeyChecking=accept-new"
          "-i"
          cfg.identityFile
          "-L"
          "127.0.0.1:${toString cfg.bindPort}:127.0.0.1:${toString cfg.remoteForwardPort}"
          "-p"
          (toString cfg.remotePort)
          "-l"
          cfg.user
          cfg.remoteHost
        ];
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}