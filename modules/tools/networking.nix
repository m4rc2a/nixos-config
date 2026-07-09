{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    dig
    rsync
    wget
  ];
}
