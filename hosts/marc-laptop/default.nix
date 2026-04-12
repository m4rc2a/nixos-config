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

  # TODO: Re-enable when home-manager submodule is fixed
  # home-manager = {
  #   useGlobalPkgs = true;
  #   useUserPackages = true;
  #   extraSpecialArgs = {
  #     inherit inputs;
  #     homeManagerInputs = {
  #       home-manager = inputs.home-manager;
  #     };
  #   };
  #   users.marc = { pkgs, ... }: {
  #     imports = [
  #       inputs.home-manager.homeConfigurations."work-laptop-hp".homeManagerModules.default
  #     ];
  #   };
  # };

  networking.hostName = "marc-laptop";
  system.stateVersion = "25.11";
}
