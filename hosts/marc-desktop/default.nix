{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-profiles.nixosProfiles.gaming-pc
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.xbootldrMountPoint = "/boot";
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/efi";
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
    inputs.plasma-manager.homeModules.plasma-manager
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
