{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-profiles.nixosProfiles.laptop
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  custom.users.main.groups = ["wheel" "video" "networkmanager" "dialout" "adbusers" "docker" "plugdev"];

  environment.systemPackages = with pkgs; [
    usbutils
    vim
    helix
    yazi
  ];

  custom.home-manager.users.marc = [
    inputs.hm-chammy.homeManagerModules.core
    inputs.hm-chammy.homeManagerModules.desktop
  ];

  networking.hostName = "marc-laptop";
  system.stateVersion = "25.11";
}
