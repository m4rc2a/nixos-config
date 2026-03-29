{pkgs, ...}: {
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    glibc
    gtk3
    glib
    gobject-introspection
    dbus
    nss
    nspr
    cups
    libdrm
    pango
    cairo
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    libxkbcommon
    xorg.libxcb
    alsa-lib
    at-spi2-core
    atk
    atkmm
    pango
    libepoxy
    expat
    mesa
    libgbm
    libpulseaudio
  ];
}
