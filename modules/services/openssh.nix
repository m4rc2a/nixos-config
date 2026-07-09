{lib, ...}: {
  config = {
    services.openssh = {
      enable = true;
      ports = lib.mkDefault [22];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    custom.services.ports.openssh.tcp = [22];
    custom.services.ports.openssh.udp = [];
  };
}
