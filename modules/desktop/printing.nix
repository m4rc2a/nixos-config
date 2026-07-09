{pkgs, ...}: {
  services.printing = {
    enable = true;
    drivers = [pkgs.gutenprint];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    gutenprint
    cups-filters
  ];
}
