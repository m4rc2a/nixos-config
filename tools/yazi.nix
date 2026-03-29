{
  pkgs,
  flexoki-dark-yazi,
  flexoki-light-yazi,
  ...
}: {
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;

    flavors = {
      flexoki-dark = flexoki-dark-yazi;
      flexoki-light = flexoki-light-yazi;
    };

    settings = {
      yazi = {
        mgr = {
          show_hidden = true;
        };
      };

      # flavor.use = "flexoki-dark";
    };
  };

  environment.systemPackages = with pkgs; [
    file
  ];
}
