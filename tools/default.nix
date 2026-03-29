{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../tools/helix.nix
    ../tools/yazi.nix
    ../tools/git.nix
  ];

  environment.systemPackages = with pkgs; [
    tree
    ripgrep
  ];
}
