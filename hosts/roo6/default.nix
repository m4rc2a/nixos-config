{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../profiles/server.nix
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops

    ./disk-config.nix
    ./hardware-configuration.nix
    ./network-interfaces.nix
  ];

  nixpkgs.config.allowUnfree = true;

  users.users.marc = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHb/tElkqPSkzQnH2NA+B8M0VaeXyng0x6hfTGtLN7X"
    ];
    initialPassword = "changeme";
  };

  # Disable AppArmor for now
  security.apparmor.enable = lib.mkForce false;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.udisks2.enable = true;

  # Firewall zones
  custom.firewall.exposedByZone = {
    lan = ["nginx" "matter-server" "homeassistant" "openssh" "gitlab" "invidious" "radarr" "jellyfin"];
    wan = ["nginx" "matter-server" "homeassistant" "jellyfin"];
  };

  # Service overrides
  services.home-assistant.config.homeassistant = {
    latitude = 52.155262;
    longitude = 10.517174;
  };

  services.gitlab = {
    initialRootPasswordFile = "/var/secrets/gitlab/initial_root_password";
    databasePasswordFile = "/var/secrets/gitlab/database_password";
    secrets = {
      secretFile = "/var/secrets/gitlab/secret_key_base";
      otpFile = "/var/secrets/gitlab/otp_key_base";
      dbFile = "/var/secrets/gitlab/encryption_key";
      jwsFile = "/var/secrets/gitlab/jws_key";
      activeRecordPrimaryKeyFile = "/var/secrets/gitlab/active_record_primary_key";
      activeRecordDeterministicKeyFile = "/var/secrets/gitlab/active_record_deterministic_key";
      activeRecordSaltFile = "/var/secrets/gitlab/active_record_salt";
    };
  };

  sops.defaultSopsFile = "${inputs.nixos-secrets}/secrets.yaml";
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.secrets = {
    ssh-tunnel-key = {
      path = "/var/lib/sshtunnel/.ssh/id_ed25519";
      owner = "sshtunnel";
      group = "sshtunnel";
      mode = "0600";
    };
    gitlab-initial-root-password = {
      path = "/var/secrets/gitlab/initial_root_password";
      mode = "0600";
    };
    gitlab-database-password = {
      path = "/var/secrets/gitlab/database_password";
      mode = "0600";
    };
    gitlab-secret-key-base = {
      path = "/var/secrets/gitlab/secret_key_base";
      mode = "0600";
    };
    gitlab-otp-key-base = {
      path = "/var/secrets/gitlab/otp_key_base";
      mode = "0600";
    };
    gitlab-encryption-key = {
      path = "/var/secrets/gitlab/encryption_key";
      mode = "0600";
    };
    gitlab-jws-key = {
      path = "/var/secrets/gitlab/jws_key";
      mode = "0600";
    };
    gitlab-activerecord-primary-key = {
      path = "/var/secrets/gitlab/active_record_primary_key";
      mode = "0600";
    };
    gitlab-activerecord-deterministic-key = {
      path = "/var/secrets/gitlab/active_record_deterministic_key";
      mode = "0600";
    };
    gitlab-activerecord-salt = {
      path = "/var/secrets/gitlab/active_record_salt";
      mode = "0600";
    };
  };

  custom.services.ssh-reverse-tunnel.enable = true;
  custom.services.ssh-reverse-tunnel.remoteHost = "shelog";
  custom.services.ssh-reverse-tunnel.tunnelPort = 2443;

  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
  ];

  home-manager.users.marc = {
    imports = [
      "${inputs.hm-config}/modules/ssh-zones.nix"
      "${inputs.hm-config}/profiles/core/default.nix"
    ];
  };

  home-manager.users.root = {
    imports = [
      "${inputs.hm-config}/modules/ssh-zones.nix"
      "${inputs.hm-config}/profiles/core/default.nix"
    ];
  };

  networking.hostName = "roo6";
  hardware.enableRedistributableFirmware = true;
  zramSwap.enable = true;
  system.stateVersion = "25.05";
}
