{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./hardware-configuration.nix

    # WSL feature
    ../../../features/wsl
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
    users.wsl = { pkgs, ... }: {
      imports = [
        inputs.home-manager.homeConfigurations."default".homeManagerModules.default
      ];
    };
  };

  networking.hostName = "wsl";
  wsl.enable = true;
  system.stateVersion = "25.05";
}
