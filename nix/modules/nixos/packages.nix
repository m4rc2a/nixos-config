{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    doas-sudo-shim
    trash-cli
    wget
    vlock
    tmux
    lsof
  ];
}
