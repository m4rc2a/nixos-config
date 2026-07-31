{...}: {
  config = {
    services.matter-server = {
      enable = true;
      openFirewall = true;
    };
  };
}
