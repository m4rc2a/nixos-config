{
  inputs,
  nixos_secrets,
  ...
}: {
  imports = [
    "${inputs.hm-config}/hosts/desktop-pc.nix"
    inputs.niri.homeModules.niri
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/etc/sops/age/keys.txt";
    age.generateKey = true;
    defaultSopsFile = "${nixos_secrets}/secrets.yaml";

    secrets = {
      home_ed25519 = {
        path = "/home/marc/.ssh/home/home_ed25519";
        mode = "0600";
      };
      codeberg_ed25519_personal = {
        path = "/home/marc/.ssh/private/codeberg_ed25519_personal";
        mode = "0600";
      };
      id_ed25519_stratum0 = {
        path = "/home/marc/.ssh/stratum0/id_ed25519_stratum0";
        mode = "0600";
      };
      shelog_ed25519 = {
        path = "/home/marc/.ssh/stratum0/shelog_ed25519";
        mode = "0600";
      };
    };
  };
}
