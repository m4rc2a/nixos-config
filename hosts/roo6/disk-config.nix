{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1"; # VERIFY: lsblk -f auf roo6
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["fmask=0022" "dmask=0022"];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/";
                mountOptions = ["compress=zstd" "noatime"];
              };
            };
          };
        };
      };
      data = {
        type = "disk";
        device = "/dev/nvme1n1"; # VERIFY: lsblk -f auf roo6
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/media/data";
                mountOptions = ["defaults"];
              };
            };
          };
        };
      };
    };
  };
}
