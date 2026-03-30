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

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.05";
}
