{pkgs, ...}: {
  imports = [
    # Base
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/networking.nix
    ../modules/home-manager.nix
    ../modules/packages.nix
    ../modules/tools
    ../modules/nano-replacement.nix

    # Desktop
    ../modules/desktop/greetd.nix
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
    ../modules/security/apparmor.nix
  ];

  custom.greetd.session = "sway";

  services.gvfs.enable = true;
  services.geoclue2.enable = true;

  systemd.services.systemd-udev-settle.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  programs.firefox.enable = true;

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}
