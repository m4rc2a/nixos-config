{ pkgs, lib, config, ... }:

{
  options.custom.security.apparmor = {
    enable = lib.mkEnableOption "AppArmor";
    mode = lib.mkOption {
      type = lib.types.enum [ "complain" "enforce" ];
      default = "complain";
      description = "Default mode for AppArmor profiles";
    };
  };

  config = lib.mkIf config.custom.security.apparmor.enable {
    security.apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      policies = {
        # Add profiles here after collecting logs with aa-logprof
      };
    };

    environment.systemPackages = with pkgs; [
      apparmor-utils   # aa-logprof, aa-enforce, aa-complain
      apparmor-parser
    ];

    # Audit daemon for logging AppArmor events
    security.audit.enable = true;

    # Cache profiles for faster boot
    security.apparmor.packages = [ pkgs.apparmor-profiles ];
  };
}
