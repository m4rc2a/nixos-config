{
  description = "Local NixOS host configurations";

  nixConfig = {
    extra-substituters = ["https://nixos-raspberrypi.cachix.org"];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixos-profiles.url = "git+https://codeberg.org/m4rc2a/nixos-profiles";

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

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi";
      inputs.nixpkgs.follows = "nixpkgs";
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

      rpi5-webserver = inputs.nixos-raspberrypi.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.page-size-16k
          ./hosts/rpi5-webserver
        ];
      };

      rpi5-webserver-installer = inputs.nixos-raspberrypi.lib.nixosInstaller {
        system = "aarch64-linux";
        specialArgs = {inherit inputs self;};
        modules = [
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.page-size-16k
          ./hosts/rpi5-webserver/installer.nix
        ];
      };
    };
  };
}
