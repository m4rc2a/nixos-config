{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.android-tools
  ];

  services.udev.packages = [
    pkgs.sigrok-firmware-fx2lafw
  ];
}
