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

  users.users.marc = {
    isNormalUser = true;
    extraGroups = ["wheel" "video" "networkmanager" "dialout" "adbusers" "docker" "plugdev"];
  };

  environment.systemPackages = with pkgs; [
    usbutils
    vim
    helix
    yazi
  ];

  home-manager.users.marc = {
    imports = [
      inputs.hm-chammy.homeManagerModules.core
      inputs.hm-chammy.homeManagerModules.desktop
    ];
  };

  networking.hostName = "marc-laptop";
  system.stateVersion = "25.11";
}
