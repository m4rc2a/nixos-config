{pkgs, ...}: {
  # SSH Tunnel user
  users.users.sshtunnel = {
    isSystemUser = true;
    home = "/var/lib/sshtunnel";
    shell = "${pkgs.shadow}/bin/nologin";
    createHome = true;
    group = "sshtunnel";
  };

  users.groups.sshtunnel = {};

  # SSH Tunnel service
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
      ExecStart = ''
        ${pkgs.autossh}/bin/autossh \
          -M 0 \
          -N \
          -R 2443:localhost:22 \
          -i /var/lib/sshtunnel/.ssh/id_ed25519 \
          -o ServerAliveInterval=60 \
          -o ServerAliveCountMax=3 \
          -o ExitOnForwardFailure=yes \
          shelog
      '';
      Restart = "always";
      RestartSec = "10s";
    };
  };
}
