{inputs, ...}: {
  imports = [
    # Base modules
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/networking.nix
    ../modules/users.nix
    ../modules/packages.nix
    ../tools

    # Desktop
    ../modules/desktop/sway.nix
    ../modules/desktop/pipewire.nix
    ../modules/desktop/bluetooth.nix
    ../modules/desktop/printing.nix
    ../modules/desktop/adb.nix

    # Virtualization
    ../modules/virtualization/podman.nix
    ../modules/virtualization/waydroid.nix

    # Gaming
    ../modules/gaming/steam.nix

    # Development
    ../modules/development/nix-ld.nix

    # Security
    ../modules/security/doas.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Services
  services.gvfs.enable = true;
  services.geoclue2.enable = true;

  # Speed up boot
  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  # Firefox
  programs.firefox.enable = true;
}
