{pkgs, ...}: let
  swayConfig = pkgs.writeText "greetd-sway-config" ''
    exec systemctl --user import-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK XCURSOR_SIZE XCURSOR_THEME &

    exec "${pkgs.gtkgreet}/bin/gtkgreet -l; swaymsg exit"
    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'
  '';
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.sway}/bin/sway --config ${swayConfig}";
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    sway
    bash
  '';

  programs.light.enable = true;

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
    gtkgreet
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
