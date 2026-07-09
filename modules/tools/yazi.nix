{pkgs, ...}: {
  config = {
    programs.yazi = {
      enable = true;
      package = pkgs.yazi;

      settings = {
        yazi = {
          mgr = {
            show_hidden = true;
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      file
      trash-cli
    ];
  };
}
