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

  networking.hostName = "roo6";
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.05";
}
