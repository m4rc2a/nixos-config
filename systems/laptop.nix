{pkgs, ...}: {
  imports = [
    # Base
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/networking.nix
    ../modules/nano-replacement.nix

    # tools
    ../modules/tools/files.nix
    ../modules/tools/processes.nix
    ../modules/tools/networking.nix
    ../modules/tools/tmux.nix
    ../modules/tools/hardware.nix
    ../modules/tools/helix.nix
    ../modules/tools/archives.nix
    ../modules/tools/data.nix

    # Desktop
    ../modules/desktop/greetd.nix
    ../modules/desktop/sway.nix
    ../modules/desktop/pipewire.nix
    ../modules/desktop/bluetooth.nix
    ../modules/desktop/printing.nix

    # Virtualization
    ../modules/virtualization/podman.nix
    ../modules/virtualization/waydroid.nix

    # Gaming
    ../modules/gaming/steam.nix

    # Security
    ../modules/security/apparmor.nix
  ];

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
