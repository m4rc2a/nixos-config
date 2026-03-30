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

  networking.hostName = "wsl";
  wsl.enable = true;
  system.stateVersion = "25.05";
}
