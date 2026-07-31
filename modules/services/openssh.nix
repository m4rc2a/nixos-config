{lib, ...}: {
  config = {
    services.openssh = {
      enable = true;
      openFirewall = true;
      ports = lib.mkDefault [22];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

  };
}
