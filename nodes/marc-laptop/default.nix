{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../systems/laptop.nix
    ../../modules/stylix.nix
    inputs.disko.nixosModules.default
    inputs.sops-nix.nixosModules.sops

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

  sops.defaultSopsFile = "${inputs.nixos-secrets}/secrets.yaml";
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.age.generateKey = true;

  networking.hostName = "marc-laptop";
  system.stateVersion = "25.11";
}
