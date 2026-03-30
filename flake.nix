{
  description = "Unified NixOS configuration with Snowfall Lib";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/release-25.11";
    disko.url = "github:nix-community/disko";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flexoki-dark-yazi = {
      url = "github:gosxrgxx/flexoki-dark.yazi";
      flake = false;
    };

    flexoki-light-yazi = {
      url = "github:gosxrgxx/flexoki-light.yazi";
      flake = false;
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        root = ./nix;
        namespace = "custom";
      };
    };
  in
    lib // {
      colmenaHive = inputs.colmena.lib.makeHive {
        meta = {
          nixpkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            overlays = [];
          };
          nodeNixpkgs = {
            roo6 = import inputs.nixpkgs {
              system = "aarch64-linux";
              overlays = [];
            };
          };
          specialArgs = { inherit inputs; };
        };

        roo6 = {
          imports = [
            ./nix/systems/aarch64-linux/roo6
            ./nix/systems/aarch64-linux/roo6/colmena.nix
          ];
        };

        marc-laptop = {
          imports = [
            ./nix/systems/x86_64-linux/marc-laptop
            ./nix/systems/x86_64-linux/marc-laptop/colmena.nix
          ];
        };
      };
    };
}
