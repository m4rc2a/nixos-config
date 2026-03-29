{pkgs, profile, ...}: {
  users.users = {
    marc = {
      isNormalUser = true;
      extraGroups = ["wheel"]
        ++ pkgs.lib.optionals (profile == "laptop") [
          "video"
          "networkmanager"
          "dialout"
          "adbusers"
          "docker"
          "plugdev"
        ];
    };
  };
}
