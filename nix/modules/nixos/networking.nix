{
  lib,
  config,
  ...
}: {
  networking = {
    hostName = lib.mkDefault config.system.name;
    networkmanager.enable = true;
  };
}
