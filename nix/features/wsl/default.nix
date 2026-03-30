{...}: {
  imports = [
    ../../modules/nixos/locale.nix
    ../../modules/nixos/time.nix
    ../../modules/nixos/nix.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/packages.nix
    ../../modules/nixos/nano-replacement.nix
    ../../modules/nixos/tools
  ];
}
