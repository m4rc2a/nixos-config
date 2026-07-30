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

  boot = {
    loader = {
      # GRUB im Legacy BIOS Modus — Heads bootet GRUB von der EF02 Partition
      grub = {
        enable = true;
        efiSupport = false;
        efiInstallAsRemovable = false;
      };
    };

    kernelPackages = pkgs.linuxPackages_latest;

    supportedFilesystems = ["ntfs" "btrfs" "ext4"];

    consoleLogLevel = 4;

    kernelParams = [
      "quiet"
      "splash"
      "udev.log_priority=3"
    ];

    initrd = {
      verbose = true;
      availableKernelModules = ["xhci_pci" "ahci" "sd_mod" "sr_mod"];
      kernelModules = ["dm-snapshot" "dm-crypt"];
    };

    kernelModules = ["tpm-rng"];
    extraModulePackages = [];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.enableRedistributableFirmware = true;
}
