{...}: {
  imports = [
    # Base
    ../modules/firewall.nix
    ../modules/service-ports.nix
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/home-manager.nix
    ../modules/packages.nix
    ../modules/nano-replacement.nix
    ../modules/hdparm-spindown.nix
    ../modules/tools

    # Security
    ../modules/security/apparmor.nix

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
