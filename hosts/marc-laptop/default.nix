{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-shared.nixosProfiles.laptop
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  # Main user
  custom.users.main.name = "marc";
  custom.users.main.groups = ["wheel" "video" "networkmanager" "dialout" "adbusers" "docker" "plugdev"];

  # Yazi flavors
  custom.tools.yazi.flavors = {
    flexoki-dark = inputs.flexoki-dark-yazi;
    flexoki-light = inputs.flexoki-light-yazi;
  };

  # Extra system packages (machine-specific)
  environment.systemPackages = with pkgs; [
    usbutils
    coreutils
    glib
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
    distrobox
    vim
    discord
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.marc = {
      imports = [
        inputs.hm-chammy.homeManagerModules.core
        inputs.hm-chammy.homeManagerModules.desktop
      ];
    };
  };

  networking.hostName = "marc-laptop";
  system.stateVersion = "25.11";
}
