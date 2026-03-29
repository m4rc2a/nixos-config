final: prev:
let
  lib = prev.lib;

  linuxSky1 = prev.fetchFromGitHub {
    owner = "Sky1-Linux";
    repo = "linux-sky1";
    rev = "main";
    hash = lib.fakeHash; # beim ersten Build ersetzen
  };

  # Patchliste in stabiler Reihenfolge (0001..., 0002..., ...)
  patchDir = "${linuxSky1}/patches-latest";
  patchNames = lib.sort lib.lessThan
    (lib.attrNames (builtins.readDir patchDir));

  sky1Patches =
    map (n: {
      name = "sky1-" + n;
      patch = "${patchDir}/${n}";
    })
    (lib.filter (n: lib.hasSuffix ".patch" n) patchNames);

  # Sky1 default config (Latest track)
  sky1Cfg = builtins.readFile "${linuxSky1}/config/config.sky1-latest";

  baseKernel = prev.linuxKernel.kernels.linux_latest;
in
{
  linuxKernel = prev.linuxKernel // {
    kernels = prev.linuxKernel.kernels // {
      linux_sky1_latest = baseKernel.override {
        kernelPatches = (baseKernel.kernelPatches or [ ]) ++ sky1Patches;

        # NixOS erwartet hier eher "CONFIG_FOO=y"-Zeilen; Sky1 liefert eine volle .config.
        # Oft klappt das trotzdem, aber wenn es scheitert, bauen wir auf buildLinux um.
        extraConfig = ''
          ${sky1Cfg}
        '';
      };
    };

    packages = prev.linuxKernel.packages // {
      linux_sky1_latest =
        prev.linuxKernel.packagesFor final.linuxKernel.kernels.linux_sky1_latest;
    };
  };
}
