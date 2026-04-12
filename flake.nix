{
  description = "Local NixOS host configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixos-shared.url = "git+file:///home/nixos/src/nixos-shared";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/release-25.11";
    disko.url = "github:nix-community/disko";

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: Re-enable when home-manager submodule is fixed
    # home-manager = {
    #   url = "path:./home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    flexoki-dark-yazi = {
      url = "github:gosxrgxx/flexoki-dark.yazi";
      flake = false;
    };

    flexoki-light-yazi = {
      url = "github:gosxrgxx/flexoki-light.yazi";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: {
    nixosConfigurations = {
      roo6 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs;};
        modules = [./hosts/roo6];
      };

      wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [./hosts/wsl];
      };

      marc-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [./hosts/marc-laptop];
      };
    };

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
        specialArgs = {inherit inputs;};
      };

      roo6 = {
        imports = [
          ./hosts/roo6
          ./hosts/roo6/colmena.nix
        ];
      };

      marc-laptop = {
        imports = [
          ./hosts/marc-laptop
          ./hosts/marc-laptop/colmena.nix
        ];
      };
    };
  };
}
