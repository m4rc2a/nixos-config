{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../systems/laptop.nix
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

  users.users.marc = {
    isNormalUser = true;
    extraGroups = ["wheel" "video" "networkmanager" "dialout" "adbusers" "docker" "plugdev"];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    usbutils
    vim
    helix
    yazi
  ];

  sops.defaultSopsFile = "${inputs.nixos-secrets}/secrets.yaml";
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.age.generateKey = true;

  networking.hostName = "marc-laptop";
  system.stateVersion = "25.11";
}
