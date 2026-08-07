{inputs, ...}: {
  home = {
    username = "marc";
    homeDirectory = "/home/marc";
  };

  imports = [
    "${inputs.hm-config}/modules/ssh-zones.nix"
    "${inputs.hm-config}/profiles/core/default.nix"
    "${inputs.hm-config}/platforms/server.nix"
  ];
}
