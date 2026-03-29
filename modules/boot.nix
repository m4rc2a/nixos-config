{pkgs, ...}: {
  nixpkgs.overlays = [
    (import ../overlays/linux-sky1.nix)
  ];

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
