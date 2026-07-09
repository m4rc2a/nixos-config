{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    htop
    killall
    lsof
  ];
}
