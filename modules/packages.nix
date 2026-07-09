{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    dig
    fzf
    htop
    jq
    killall
    mc
    pciutils
    rsync
    unzip
    usbutils
    vim
    zip
  ];
}
