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

  # Kernel Export für kexec (Heads BIOS)
  # Heads lädt diese Dateien direkt beim Boot
  system.activationScripts.exportKernelForHeads = ''
        mkdir -p /boot/kexec /boot/grub
        cp -f ${config.system.build.kernel}/bzImage /boot/kexec/vmlinuz
        cp -f ${config.system.build.initialRamdisk}/initrd /boot/kexec/initrd

        params="${toString config.boot.kernelParams}"
        echo "$params" > /boot/kexec/cmdline

        menu_entry="NixOS|bzImage|kernel /kexec/vmlinuz|initrd /kexec/initrd|append $params"
        echo "$menu_entry" > /boot/kexec_menu.txt
        echo "$menu_entry" > /boot/kexec_default.1.txt

        # Heads benötigt eine grub.cfg zur Erkennung des Boot-Devices
        cat > /boot/grub/grub.cfg << 'GRUB_EOF'
    GRUB_EOF
  '';

  boot = {
    # Heads nutzt kexec
    loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = false;
    };

    initrd.systemd.enable = true;

    kernelPackages = pkgs.linuxPackages_latest;

    supportedFilesystems = ["ntfs" "btrfs" "ext4"];

    consoleLogLevel = 4;

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
    ];

    initrd = {
      verbose = false;
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
