{inputs, pkgs, ...}: {
  users.users.marc.extraGroups = [
    "video"
    "networkmanager"
    "dialout"
    "adbusers"
    "docker"
    "plugdev"
  ];

  environment.systemPackages = with pkgs; [
    usbutils
    coreutils
    glib
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
    distrobox
    vim
    home-manager
    discord
  ];

  imports = [
    ../../modules/nixos/nix.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/time.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/packages.nix
    ../../modules/nixos/tools

    # Desktop
    ../../modules/nixos/desktop/sway.nix
    ../../modules/nixos/desktop/pipewire.nix
    ../../modules/nixos/desktop/bluetooth.nix
    ../../modules/nixos/desktop/printing.nix
    ../../modules/nixos/desktop/adb.nix

    # Virtualization
    ../../modules/nixos/virtualization/podman.nix
    ../../modules/nixos/virtualization/waydroid.nix

    # Gaming
    ../../modules/nixos/gaming/steam.nix

    # Development
    ../../modules/nixos/development/nix-ld.nix

    # Security
    ../../modules/nixos/security/doas.nix
  ];

  nixpkgs.config.allowUnfree = true;

  services.gvfs.enable = true;
  services.geoclue2.enable = true;

  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  programs.firefox.enable = true;
}
