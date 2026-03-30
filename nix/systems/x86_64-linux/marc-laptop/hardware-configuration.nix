{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel Export für kexec (Heads BIOS)
  # Heads lädt diese Dateien direkt beim Boot
  system.activationScripts.exportKernelForHeads = ''
    mkdir -p /boot/kexec
    cp ${config.system.build.kernel}/bzImage /boot/kexec/vmlinuz
    cp ${config.system.build.initialRamdisk}/initrd /boot/kexec/initrd
    echo "${toString config.boot.kernelParams}" > /boot/kexec/cmdline
  '';

  boot = {
    # Kein Bootloader - Heads nutzt kexec
    loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = false;
    };

    # Keine EFI-Unterstützung nötig
    initrd.systemd.enable = true;

    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ntfs" "btrfs" "ext4" ];

    consoleLogLevel = 4;

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
    ];

    initrd = {
      verbose = false;
      availableKernelModules = [ "xhci_pci" "ahci" "sd_mod" "sr_mod" ];
      kernelModules = [ "dm-snapshot" "dm-crypt" ];
    };

    kernelModules = [ "tpm-rng" ];
    extraModulePackages = [];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # TPM für Heads falls vorhanden
  hardware.enableRedistributableFirmware = true;
}
