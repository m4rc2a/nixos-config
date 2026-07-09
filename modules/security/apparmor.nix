{
  pkgs,
  lib,
  ...
}: {
  config = {
    security.apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      policies = {};
    };

    environment.systemPackages = with pkgs; [
      apparmor-utils
      apparmor-parser
    ];

    security.audit.enable = true;
    security.apparmor.packages = [pkgs.apparmor-profiles];
  };
}
