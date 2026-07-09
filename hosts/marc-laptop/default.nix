{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../profiles/laptop.nix
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  users.users.marc = {
    isNormalUser = true;
    extraGroups = ["wheel" "video" "networkmanager" "dialout" "adbusers" "docker" "plugdev"];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    usbutils
    vim
    helix
    yazi
  ];

  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
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
