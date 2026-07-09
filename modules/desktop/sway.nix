{pkgs, ...}: {
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';
  };

  environment.systemPackages = with pkgs; [
    kitty
    grim
    slurp
    wl-clipboard
    mako
    brightnessctl
  ];

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
    MOZ_USE_XINPUT2_WHEEL = "1";
    MOZ_WHEEL_SCROLL_MULTIPLIER = "75";
    XKB_DEFAULT_LAYOUT = "de";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  services.xserver = {
    enable = false;
    xkb.layout = "de";
  };
}
