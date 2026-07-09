{...}: {
  imports = [
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/nix.nix
    ../modules/home-manager.nix
    ../modules/packages.nix
    ../modules/nano-replacement.nix
    ../modules/tools
  ];

  variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}
