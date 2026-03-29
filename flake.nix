{
  description = "Unified NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/release-25.11";

    # Laptop-specific inputs
    disko.url = "github:nix-community/disko";

    flexoki-dark-yazi = {
      url = "github:gosxrgxx/flexoki-dark.yazi";
      flake = false;
    };

    flexoki-light-yazi = {
      url = "github:gosxrgxx/flexoki-light.yazi";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    disko,
    flexoki-dark-yazi,
    flexoki-light-yazi,
    ...
  }: let
    lib = nixpkgs.lib;

    mkHost = hostDir: let
      hostMeta = import (hostDir + "/host.nix");
      system = hostMeta.system;
      hostName = hostMeta.hostName;
      profile = hostMeta.profile;
    in
      lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit hostName profile flexoki-dark-yazi flexoki-light-yazi;
        };

        modules =
          [
            (hostDir + "/base.nix")
            ./profiles/${profile}.nix
          ]
          ++ lib.optional (profile == "wsl") nixos-wsl.nixosModules.default
          ++ lib.optionals (profile == "laptop") [
            disko.nixosModules.default
          ];
      };

    hosts = {
      roo6 = ./hosts/roo6;
      wsl = ./hosts/wsl;
      marc-laptop = ./hosts/marc-laptop;
    };
  in {
    nixosConfigurations =
      lib.mapAttrs (_: hostDir: mkHost hostDir) hosts;
  };
}
