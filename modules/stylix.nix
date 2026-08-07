{lib, pkgs, inputs, ...}: {
  # System-level Stylix (source of truth for the theme).
  #
  # When Stylix is enabled alongside Home Manager, the NixOS module
  # (homeManagerIntegration.autoImport + followSystem) automatically:
  #   - imports stylix.homeModules.stylix for every home-manager user
  #   - forwards this theme (base16Scheme, enable, fonts, icons, ...) to them
  # So home-manager uses the theme set here by default.
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;
    overlays.enable = false;
    enableReleaseChecks = false;

    # Colors only — no wallpaper (stylix.image intentionally unset).
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";

    autoEnable = true;

    targets = {
      console.enable = lib.mkDefault true;
      gtk.enable = lib.mkDefault true;
      qt.enable = lib.mkDefault true;
      # ReGreet target targets `programs.regreet`; none of these hosts use it.
      regreet.enable = false;
    };
  };
}
