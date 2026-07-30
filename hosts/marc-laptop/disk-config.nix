{
  # Legacy BIOS-kompatible Partitionierung mit GPT + EF02
  # Heads bootet GRUB von der BIOS Boot Partition, GRUB lädt Kernel+Initrd von /boot
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/ata-TS64GMTS552T2_I769290100";
        content = {
          type = "gpt";
          partitions = {
            # BIOS Boot Partition für GRUB Core Image (legacy BIOS auf GPT)
            biosBoot = {
              size = "1M";
              type = "EF02";
            };
            # Unverschlüsselte Boot-Partition für GRUB
            boot = {
              size = "512M";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
                mountOptions = ["noatime"];
              };
            };
            # Verschlüsselte Root-Partition mit LUKS
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "16G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
