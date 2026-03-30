{
  pkgs,
  inputs,
  ...
}: {
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;

    flavors = {
      flexoki-dark = inputs.flexoki-dark-yazi;
      flexoki-light = inputs.flexoki-light-yazi;
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
