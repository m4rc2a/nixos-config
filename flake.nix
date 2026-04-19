{
  description = "Local NixOS host configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixos-shared.url = "git+file:///home/nixos/src/nixos-shared";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/release-25.11";
    disko.url = "github:nix-community/disko";
    nixos-anywhere.url = "github:numtide/nixos-anywhere";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hm-chammy = {
      url = "git+https://codeberg.org/m4rc2a/home-manager";
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
  };
}
