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

  system.stateVersion = "25.11";
}
