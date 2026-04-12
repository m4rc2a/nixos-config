{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-shared.nixosProfiles.wsl
    inputs.nixos-wsl.nixosModules.default

    ./hardware-configuration.nix
  ];

  # No main user — nixos-wsl creates its own "wsl" user
  # No doas — WSL has limited kernel support

  # Yazi flavors
  custom.tools.yazi.flavors = {
    flexoki-dark = inputs.flexoki-dark-yazi;
    flexoki-light = inputs.flexoki-light-yazi;
  };

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
  #   users.wsl = { pkgs, ... }: {
  #     imports = [
  #       inputs.home-manager.homeConfigurations."default".homeManagerModules.default
  #     ];
  #   };
  # };

  networking.hostName = "wsl";
  wsl.enable = true;
  system.stateVersion = "25.05";
}
