{pkgs, ...}: {
  imports = [./yazi.nix];
  environment.systemPackages = with pkgs; [
    ripgrep
    tree
  ];
}
