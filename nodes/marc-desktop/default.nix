{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../systems/gaming-pc.nix
    ../../modules/stylix.nix
    ../../modules/services/roo6-web-tunnel.nix
    inputs.disko.nixosModules.default
    inputs.sops-nix.nixosModules.sops

    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  networking.hosts."127.0.0.1" = [
    "zander.cloud"
    "git.zander.cloud"
    "hass.zander.cloud"
    "jellyfin.zander.cloud"
    "invidious.zander.cloud"
    "radarr.zander.cloud"
  ];

  custom.services.roo6-web-tunnel.enable = true;
  custom.services.roo6-web-tunnel.identityFile = "/home/marc/.ssh/stratum0/shelog_ed25519";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.udisks2.enable = true;

  hardware.enableRedistributableFirmware = true;

  nixpkgs.config.allowUnfree = true;

  users.users.marc = {
    isNormalUser = true;
    extraGroups = ["wheel" "video" "networkmanager" "audio"];
    initialPassword = "changeme";
  };

  sops.defaultSopsFile = "${inputs.nixos-secrets}/secrets.yaml";
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.age.generateKey = true;

  networking.hostName = "marc-desktop";
  system.stateVersion = "25.11";
}
