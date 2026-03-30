{pkgs, ...}: let
  linux-sky1-overlay = final: prev: let
    lib = prev.lib;
    linuxSky1 = prev.fetchFromGitHub {
      owner = "Sky1-Linux";
      repo = "linux-sky1";
      rev = "main";
      hash = lib.fakeHash;
    };
    patchDir = "${linuxSky1}/patches-latest";
    patchNames = lib.sort lib.lessThan (lib.attrNames (builtins.readDir patchDir));
    sky1Patches = map (n: {
      name = "sky1-" + n;
      patch = "${patchDir}/${n}";
    }) (lib.filter (n: lib.hasSuffix ".patch" n) patchNames);
    sky1Cfg = builtins.readFile "${linuxSky1}/config/config.sky1-latest";
    baseKernel = prev.linuxKernel.kernels.linux_latest;
  in {
    linuxKernel = prev.linuxKernel // {
      kernels = prev.linuxKernel.kernels // {
        linux_sky1_latest = baseKernel.override {
          kernelPatches = (baseKernel.kernelPatches or []) ++ sky1Patches;
          extraConfig = ''
            ${sky1Cfg}
          '';
        };
      };
      packages = prev.linuxKernel.packages // {
        linux_sky1_latest = prev.linuxKernel.packagesFor final.linuxKernel.kernels.linux_sky1_latest;
      };
    };
  };
in {
  nixpkgs.overlays = [linux-sky1-overlay];

  boot = {
    loader = {
      systemd-boot.enable = true;
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };

    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxKernel.packages.linux_sky1_latest;
  };
}
