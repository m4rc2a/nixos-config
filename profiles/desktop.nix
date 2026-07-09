{pkgs, ...}: {
  imports = [
    # Basis
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/networking.nix
    ../modules/home-manager.nix
    ../modules/packages.nix
    ../modules/nano-replacement.nix
    ../modules/tools

    # Desktop
    ../modules/desktop/greetd.nix
    ../modules/desktop/plasma.nix
    ../modules/desktop/pipewire.nix
    ../modules/desktop/bluetooth.nix
    ../modules/desktop/printing.nix
  ];

  custom.greetd.session = "plasma";

  services.gvfs.enable = true;

  programs.firefox.enable = true;

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}
