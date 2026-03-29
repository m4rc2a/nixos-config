{lib, ...}: {
  imports = [
    # Base/System
    ../modules/boot.nix
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/networking.nix
    ../modules/nix.nix
    ../modules/security.nix
    ../modules/users.nix
    ../modules/packages.nix
    ../modules/storage.nix
    ../modules/hdparm-spindown.nix
    ../tools
    ../modules/nano-replacement.nix

    # Services
    ../services/gitea.nix
    ../services/homeassistant.nix
    ../services/i2p.nix
    ../services/invidious.nix
    ../services/jellyfin.nix
    ../services/matter-server.nix
    ../services/nginx.nix
    ../services/openssh.nix
    ../services/radarr.nix

    # lokal
    ../services/ssh-reverse-tunnel.nix

    # Exposurelisten
    ./server/exposed-lan.nix
    ./server/exposed-wan.nix

    # Portliste für services
    ./server/ports.nix
  ];

  options.custom.profile.server.exposedByZone = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    default = {};
    description = "Zone -> list of service names to expose in that zone.";
  };
}
