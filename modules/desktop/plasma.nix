{pkgs, ...}: {
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    kdePackages.kate
  ];

  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "de";
  };

  services.xserver = {
    enable = false;
    xkb.layout = "de";
  };
}
