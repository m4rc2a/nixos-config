{
  lib,
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
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "roo6";

  users.users.marc = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHb/tElkqPSkzQnH2NA+B8M0VaeXyng0x6hfTGtLN7X"
    ];
    initialPassword = "changeme";
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.udisks2.enable = true;

  # Service overrides
  services.home-assistant.config.homeassistant = {
    latitude = 52.155262;
    longitude = 10.517174;
  };

  # Secrets
  sops.defaultSopsFile = "${inputs.nixos-secrets}/secrets.yaml";
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.secrets = {
    shelog_ed25519 = {
      path = "/var/lib/sshtunnel/.ssh/id_ed25519";
      owner = "sshtunnel";
      group = "sshtunnel";
      mode = "0600";
    };
  };

  custom.services.ssh-reverse-tunnel.enable = true;
  custom.services.ssh-reverse-tunnel.remoteHost = "shelog.stratum0.org";
  custom.services.ssh-reverse-tunnel.user = "marc";
  custom.services.ssh-reverse-tunnel.sshPort = 20022;
  custom.services.ssh-reverse-tunnel.tunnelPort = 2443;

  home-manager.sharedModules = [
    inputs.stylix.homeModules.stylix
    {
      stylix.targets = {
        gtk.enable = false;
        eog.enable = false;
        gnome-text-editor.enable = false;
        gnome.enable = false;
      };
    }
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

  hardware.enableRedistributableFirmware = true;
  zramSwap.enable = true;

  system.stateVersion = "25.05";
}
