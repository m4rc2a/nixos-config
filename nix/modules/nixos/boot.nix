{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.boot;
  linux-sky1-overlay = final: prev: let
    l = prev.lib;
    linuxSky1 = prev.fetchFromGitHub {
      owner = "Sky1-Linux";
      repo = "linux-sky1";
      rev = "main";
      hash = "sha256-cPQdu9pTNsn3gAcX5kr8VxxLMorD8FQoDFu7t63Zo2A=";
    };
    patchDir = "${linuxSky1}/patches-latest";
    patchNames = l.sort l.lessThan (l.attrNames (builtins.readDir patchDir));
    sky1Patches = map (n: {
      name = "sky1-" + n;
      patch = "${patchDir}/${n}";
    }) (l.filter (n: l.hasSuffix ".patch" n) patchNames);
    sky1Cfg = builtins.readFile "${linuxSky1}/config/config.sky1-latest";
    baseKernel = prev.linuxKernel.kernels.linux_latest;
  in {
    linuxKernel =
      prev.linuxKernel
      // {
        kernels =
          prev.linuxKernel.kernels
          // {
            linux_sky1_latest = baseKernel.override {
              kernelPatches = (baseKernel.kernelPatches or []) ++ sky1Patches;
              extraConfig = ''
                ${sky1Cfg}
              '';
            };
          };
        packages =
          prev.linuxKernel.packages
          // {
            linux_sky1_latest = prev.linuxKernel.packagesFor final.linuxKernel.kernels.linux_sky1_latest;
          };
      };
  };
in {
  options.custom.boot.sky1Kernel = {
    enable = lib.mkEnableOption "Sky1 kernel with hardware-specific patches";
  };

  config = {
    nixpkgs.overlays = lib.mkIf cfg.sky1Kernel.enable [linux-sky1-overlay];

    boot = {
      loader = {
        systemd-boot.enable = true;
        timeout = 0;
        efi.canTouchEfiVariables = true;
      };

      kernelPackages = lib.mkIf cfg.sky1Kernel.enable pkgs.linuxKernel.packages.linux_sky1_latest;
    };
  };
}
