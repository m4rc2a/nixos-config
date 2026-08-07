{pkgs, ...}: {
  imports = [
    # Basis
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/networking.nix
    ../modules/packages.nix
    ../modules/nano-replacement.nix
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
    ../modules/desktop/plasma.nix
    ../modules/desktop/pipewire.nix
    ../modules/desktop/bluetooth.nix
    ../modules/desktop/printing.nix
  ];

  services.gvfs.enable = true;

  programs.firefox.enable = true;

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}
