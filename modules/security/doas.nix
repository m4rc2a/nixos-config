{pkgs, ...}: {
  security.polkit.enable = true;

  security.doas.enable = true;
  security.sudo.enable = false;

  security.doas.extraRules = [
    {
      users = ["marc"];
      keepEnv = true;
      persist = true;
    }
  ];

  environment.systemPackages = with pkgs; [
    doas-sudo-shim
  ];
}
