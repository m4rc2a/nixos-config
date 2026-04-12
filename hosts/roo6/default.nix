{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-shared.nixosProfiles.server

    ./hardware-configuration.nix
    ./network-interfaces.nix
    ./storage.nix
  ];

  # No main user — server runs as root
  # custom.users.main.name remains null (no user created)

  # Firewall zones
  custom.firewall.exposedByZone = {
    lan = ["nginx" "matter-server" "homeassistant" "openssh" "gitea" "invidious" "radarr" "jellyfin"];
    wan = ["nginx" "matter-server" "homeassistant" "jellyfin"];
  };

  # Service overrides
  custom.services.homeassistant.latitude = 52.155262;
  custom.services.homeassistant.longitude = 10.517174;

  custom.services.ssh-reverse-tunnel.enable = true;
  custom.services.ssh-reverse-tunnel.remoteHost = "shelog";
  custom.services.ssh-reverse-tunnel.tunnelPort = 2443;

  # TODO: Re-enable when home-manager submodule is fixed
  # home-manager = {
  #   useGlobalPkgs = true;
  #   useUserPackages = true;
  #   extraSpecialArgs = {
  #     inherit inputs;
  #     homeManagerInputs = {
  #       home-manager = inputs.home-manager;
  #     };
  #   };
  #   users.root = { pkgs, ... }: {
  #     imports = [
  #       inputs.home-manager.homeConfigurations."default".homeManagerModules.default
  #     ];
  #   };
  # };

  networking.hostName = "roo6";
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "25.05";
}
