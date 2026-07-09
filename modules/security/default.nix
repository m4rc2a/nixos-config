{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vlock
  ];
}
