{...}: {
  fileSystems."/media/data" = {
    device = "/dev/disk/by-uuid/518437fc-5338-493b-b51d-38ada3687b72";
    fsType = "btrfs";
    options = ["defaults"];
  };
}
