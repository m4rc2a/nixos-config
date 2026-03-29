{...}: {
  imports = [
    ./hardware-configuration.nix
    ./network-interfaces.nix
  ];

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "25.05";
}
