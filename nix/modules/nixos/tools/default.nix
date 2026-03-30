{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./helix.nix
    ./yazi.nix
    ./git.nix
  ];

  environment.systemPackages = with pkgs; [
    tree
    ripgrep
  ];
}
