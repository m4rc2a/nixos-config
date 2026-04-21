{lib, ...}: {
  boot.initrd.availableKernelModules = ["usb_storage" "usbhid" "sdhci_pci" "sdhci"];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = ["noatime"];
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  networking.useDHCP = lib.mkDefault false;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
