{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-profiles.nixosProfiles.server
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.home-manager

    ./disk-config.nix
    ./hardware-configuration.nix
    ./network-interfaces.nix
  ];

  custom.users.main.create = true;
  custom.users.main.groups = ["wheel"];

  users.users.marc.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHb/tElkqPSkzQnH2NA+B8M0VaeXyng0x6hfTGtLN7X"
  ];
  users.users.marc.initialPassword = "changeme";

  # Disable AppArmor for now
  custom.security.apparmor.enable = lib.mkForce false;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Firewall zones
  custom.firewall.exposedByZone = {
    lan = ["nginx" "matter-server" "homeassistant" "openssh" "gitlab" "invidious" "radarr" "jellyfin"];
    wan = ["nginx" "matter-server" "homeassistant" "jellyfin"];
  };

  # Service overrides
  custom.services.homeassistant.latitude = 52.155262;
  custom.services.homeassistant.longitude = 10.517174;

  custom.services.gitlab = {
    initialRootPasswordFile = "/var/secrets/gitlab/initial_root_password";
    databasePasswordFile = "/var/secrets/gitlab/database_password";
    secretFile = "/var/secrets/gitlab/secret_key_base";
    otpFile = "/var/secrets/gitlab/otp_key_base";
    dbFile = "/var/secrets/gitlab/encryption_key";
    jwsFile = "/var/secrets/gitlab/jws_key";
    activeRecordPrimaryKeyFile = "/var/secrets/gitlab/active_record_primary_key";
    activeRecordDeterministicKeyFile = "/var/secrets/gitlab/active_record_deterministic_key";
    activeRecordSaltFile = "/var/secrets/gitlab/active_record_salt";
  };

  custom.services.ssh-reverse-tunnel.enable = true;
  custom.services.ssh-reverse-tunnel.remoteHost = "shelog";
  custom.services.ssh-reverse-tunnel.tunnelPort = 2443;

  custom.home-manager.users.marc = [
    inputs.hm-chammy.homeManagerModules.core
  ];

  custom.home-manager.users.root = [
    inputs.hm-chammy.homeManagerModules.core
  ];

  networking.hostName = "roo6";
  hardware.enableRedistributableFirmware = true;
  zramSwap.enable = true;
  system.stateVersion = "25.05";
}
