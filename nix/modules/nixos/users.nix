{pkgs, ...}: {
  users.users.marc = {
    isNormalUser = true;
    extraGroups = ["wheel"];
  };
}
