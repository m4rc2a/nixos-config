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

  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
    inputs.niri.homeModules.niri
  ];

  home-manager.users.marc = {lib, ...}: {
    imports = [
      "${inputs.hm-config}/hosts/desktop-pc.nix"
    ];
    home.username = lib.mkForce "marc";
    home.homeDirectory = lib.mkForce "/home/marc";
  };

  networking.hostName = "marc-desktop";
  system.stateVersion = "25.11";
}
