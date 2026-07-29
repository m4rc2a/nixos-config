{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ../../profiles/gaming-pc.nix
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops

    ./hardware-configuration.nix
    ./disk-config.nix
  ];

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

  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
    inputs.niri.homeModules.niri
    inputs.sops-nix.homeManagerModules.sops
  ];

  home-manager.users.marc = {lib, ...}: {
    imports = [
      "${inputs.hm-config}/hosts/desktop-pc.nix"
    ];
    home.username = lib.mkForce "marc";
    home.homeDirectory = lib.mkForce "/home/marc";

    sops.age.keyFile = "/etc/sops/age/keys.txt";
    sops.age.generateKey = true;
  sops.defaultSopsFile = "${inputs.nixos-secrets}/secrets.yaml";

    sops.secrets = {
      home_ed25519 = {
        path = "/home/marc/.ssh/home/home_ed25519";
        mode = "0600";
      };
      codeberg_ed25519_personal = {
        path = "/home/marc/.ssh/private/codeberg_ed25519_personal";
        mode = "0600";
      };
      id_ed25519_stratum0 = {
        path = "/home/marc/.ssh/stratum0/id_ed25519_stratum0";
        mode = "0600";
      };
      shelog_ed25519 = {
        path = "/home/marc/.ssh/stratum0/shelog_ed25519";
        mode = "0600";
      };
    };
  };

  networking.hostName = "marc-desktop";
  system.stateVersion = "25.11";
}
