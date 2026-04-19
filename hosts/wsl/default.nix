{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-shared.nixosProfiles.wsl
    inputs.nixos-wsl.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
  ];

  # No main user — nixos-wsl creates its own "wsl" user
  # No doas — WSL has limited kernel support

  # Yazi flavors
  custom.tools.yazi.flavors = {
    flexoki-dark = inputs.flexoki-dark-yazi;
    flexoki-light = inputs.flexoki-light-yazi;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.wsl = {
      imports = [
        inputs.hm-chammy.homeManagerModules.core
        inputs.hm-chammy.homeManagerModules.work
      ];
    };
  };

  networking.hostName = "wsl";
  wsl.enable = true;
  system.stateVersion = "25.05";
}
