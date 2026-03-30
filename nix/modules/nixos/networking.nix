{
  lib,
  ...
}: {
  networking = {
    hostName = lib.mkDefault "nixos";
    networkmanager.enable = true;
  };
}
