{...}: {
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    # settings = {
    #   default_session = {
    #     command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.custom.greetd.session}";
    #   };
    # };
  };

  # environment.etc."greetd/environments".text = ''
  #   ${config.custom.greetd.session}
  #   bash
  # '';
  # };
}
