{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./network-interfaces.nix

    # Server feature
    ../../../features/server
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
    users.root = { pkgs, ... }: {
      imports = [
        inputs.home-manager.homeConfigurations."default".homeManagerModules.default
      ];
    };
  };

  networking.hostName = "roo6";
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.05";
}
