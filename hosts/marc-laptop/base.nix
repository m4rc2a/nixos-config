{...}: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  hardware.enableRedistributableFirmware = true;

  system.stateVersion = "24.11";
}
