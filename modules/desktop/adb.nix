{pkgs, ...}: {
  programs.adb.enable = true;

  services.udev.packages = [
    pkgs.sigrok-firmware-fx2lafw
  ];
}
