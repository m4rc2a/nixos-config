{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.initrd.kernelModules = ["amdgpu"];

  boot.kernelModules = ["kvm-intel" "amdgpu"];

  boot.extraModulePackages = [];

  # fileSystems and swapDevices are managed by disko (disk-config.nix)

  # Swapfile offset for hibernation (suspend-to-disk)
  # Run `findmnt -o UUID,MOUNTPOINT /` for the root UUID and
  # `btrfs inspect-internal map-swapfile -r /.swapvol/swapfile` for the offset,
  # then add: resume=UUID=<uuid> resume_offset=<offset>
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

  boot.resumeDevice = "/dev/mapper/crypted";

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.enableRedistributableFirmware = true;
}
