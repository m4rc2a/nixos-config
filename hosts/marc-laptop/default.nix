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

  home-manager.sharedModules = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home-manager.users.marc = {
    imports = [
      "${inputs.hm-config}/modules/ssh-zones.nix"
      "${inputs.hm-config}/profiles/core/default.nix"
      "${inputs.hm-config}/profiles/desktop/default.nix"
    ];
  };

  networking.hostName = "marc-laptop";
  system.stateVersion = "25.11";
}
