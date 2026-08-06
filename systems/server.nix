{...}: {
  imports = [
    # Base
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/nix.nix
    ../modules/home-manager.nix

    # admin
    ../modules/networking.nix
    ../modules/nano-replacement.nix
    ../modules/tools/files.nix
    ../modules/tools/processes.nix
    ../modules/tools/networking.nix
    ../modules/tools/hardware.nix
    ../modules/tools/helix.nix
    ../modules/tools/archives.nix
    ../modules/tools/data.nix

    # energy
    ../modules/hdparm-spindown.nix

    # Services
    ## web
    ../modules/services/nginx.nix

    ../modules/services/invidious.nix
    ../modules/services/jellyfin.nix

    ## Home Assistant
    ../modules/services/homeassistant.nix
    ../modules/services/matter-server.nix

    ## torr
    ../modules/services/i2p.nix
    ../modules/services/radarr.nix

    ## web
    ../modules/services/forgejo.nix

    ## admin
    ../modules/services/openssh.nix
    ../modules/services/ssh-reverse-tunnel.nix
  ];

  networking.firewall.enable = true;

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}
