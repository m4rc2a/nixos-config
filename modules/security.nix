{...}: {
  security = {
    sudo.enable = false;

    doas = {
      enable = true;
      extraRules = [
        {
          users = ["marc"];
          persist = true;
        }
      ];
    };
  };
}
