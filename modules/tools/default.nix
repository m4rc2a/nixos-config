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
    lsof
    ripgrep
    tree
    wget
  ];
}
