{pkgs, profile, ...}: {
  environment.systemPackages = with pkgs; [
    doas-sudo-shim
    trash-cli
    wget
    vlock
    tmux
    lsof
  ] ++ pkgs.lib.optionals (profile == "laptop") [
    usbutils
    coreutils
    glib
    wineWowPackages.stable
    wineWowPackages.waylandFull
    winetricks
    distrobox
    vim
    home-manager
    discord
  ];
}
