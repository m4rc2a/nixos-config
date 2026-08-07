{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../systems/gaming-pc.nix
    ../../modules/stylix.nix
    inputs.disko.nixosModules.default
    inputs.sops-nix.nixosModules.sops

    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.udisks2.enable = true;

  hardware.enableRedistributableFirmware = true;

  nixpkgs.config.allowUnfree = true;

  users.users.marc = {
    isNormalUser = true;
    extraGroups = ["wheel" "video" "networkmanager" "audio"];
    initialPassword = "changeme";
  };

  sops.defaultSopsFile = "${inputs.nixos-secrets}/secrets.yaml";
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.age.generateKey = true;

  networking.hostName = "marc-desktop";
  system.stateVersion = "25.11";
}
