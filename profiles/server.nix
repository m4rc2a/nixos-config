{...}: {
  imports = [
    # Base
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/home-manager.nix
    ../modules/nano-replacement.nix
    ../modules/hdparm-spindown.nix
    ../modules/tools/files.nix
    ../modules/tools/processes.nix
    ../modules/tools/networking.nix
    ../modules/tools/tmux.nix
    ../modules/tools/hardware.nix
    ../modules/tools/helix.nix
    ../modules/tools/archives.nix
    ../modules/tools/data.nix

    # Security
    ../modules/security/apparmor.nix
    ../modules/security/firewall.nix
    ../modules/security/service-ports.nix

    # Services
    ../modules/services/gitlab.nix
    ../modules/services/homeassistant.nix
    ../modules/services/i2p.nix
    ../modules/services/invidious.nix
    ../modules/services/jellyfin.nix
    ../modules/services/matter-server.nix
    ../modules/services/nginx.nix
    ../modules/services/openssh.nix
    ../modules/services/radarr.nix
    ../modules/services/ssh-reverse-tunnel.nix
  ];

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}
