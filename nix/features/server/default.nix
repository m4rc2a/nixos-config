{lib, ...}: {
  imports = [
    # Base modules
    ../../modules/nixos/boot.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/time.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/packages.nix
    ../../modules/nixos/storage.nix
    ../../modules/nixos/hdparm-spindown.nix
    ../../modules/nixos/nano-replacement.nix
    ../../modules/nixos/tools

    # Service port definitions (must come before services)
    ../../modules/nixos/service-ports.nix

    # Services
    ./services/gitea.nix
    ./services/homeassistant.nix
    ./services/i2p.nix
    ./services/invidious.nix
    ./services/jellyfin.nix
    ./services/matter-server.nix
    ./services/nginx.nix
    ./services/openssh.nix
    ./services/radarr.nix
    ./services/ssh-reverse-tunnel.nix

    # Server-specific
    ./exposed-lan.nix
    ./exposed-wan.nix
    ./ports.nix
  ];

  options.custom.profile.server.exposedByZone = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.str);
    default = {};
    description = "Zone -> list of service names to expose in that zone.";
  };
}
