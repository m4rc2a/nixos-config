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

      # Heads-Integration: LUKS über /etc/crypttab-Override (TPM Disk Unlock Key)
      systemd.enable = true; # Default in 25.11, hier explizit gemacht
      luks.devices.crypted = {
        device = "/dev/disk/by-partlabel/disk-main-luks"; # LUKS (3. GPT-Partition)
        allowDiscards = true;
        keyFile = "/secret.key"; # von Heads (TPM DUK) injizierter Key
        # fallbackToPassword bewusst NICHT setzen: systemd fragt bei Non-DUK-Boot selbst ab.
      };
    };

    kernelModules = ["tpm-rng"];
    extraModulePackages = [];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.enableRedistributableFirmware = true;
}
