{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.disko.nixosModules.default
    ./hardware-configuration.nix
    ./disk-config.nix

    # Laptop feature
    ../../../features/laptop
  ];

  # Configure home-manager with external configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      homeManagerInputs = {
        home-manager = inputs.home-manager;
      };
    };
    users.marc = { pkgs, ... }: {
      imports = [
        inputs.home-manager.homeConfigurations."work-laptop-hp".homeManagerModules.default
      ];
    };
  };

  networking.hostName = "marc-laptop";
  system.stateVersion = "25.11";
}
