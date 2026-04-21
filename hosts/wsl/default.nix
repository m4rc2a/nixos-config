{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-profiles.nixosProfiles.wsl
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
  ];

  # No system user from custom.users.main — nixos-wsl manages the "wsl" user
  custom.users.main.create = false;

  # WSL user (required by nixos-wsl)
  users.users.wsl = {
    isNormalUser = true;
    group = "wsl";
  };
  users.groups.wsl = {};

  # Yazi flavors
  custom.tools.yazi.flavors = {
    flexoki-dark = inputs.flexoki-dark-yazi;
    flexoki-light = inputs.flexoki-light-yazi;
  };

  custom.home-manager.users.wsl = [
    inputs.hm-chammy.homeManagerModules.core
    inputs.hm-chammy.homeManagerModules.work
  ];

  networking.hostName = "wsl";
  wsl.enable = true;
  system.stateVersion = "25.05";
}
