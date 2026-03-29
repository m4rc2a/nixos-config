{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/time.nix
    ../modules/users.nix
    ../tools
  ];

  nixpkgs.config.allowUnfree = true;

  wsl = {
    enable = true;
    defaultUser = "nixos";
    interop = {
      includePath = true;
      register = true;
    };
    ssh-agent = {
      enable = true;
      users = [config.wsl.defaultUser];
    };
  };

  programs.fish.enable = true;
}
