{
  description = "Private NixOS host configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    disko.url = "github:nix-community/disko";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hm-config = {
      url = "git+ssh://git@codeberg.org/m4rc2a/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-secrets = {
      url = "git+file:///home/nixos/src/nixos-secrets";
      flake = false;
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    deploy-rs,
    ...
  }: let
    # Per-system package set with the deploy-rs package from nixpkgs (for the
    # binary cache) and the matching deploy-rs lib from the input.
    pkgsFor = system: {
      pkgs = import nixpkgs {inherit system;};
      deployPkgs = deploy-rs.lib.${system};
    };

    deployRsPkg = system: (pkgsFor system).pkgs.deploy-rs;

    # Arguments shared by every NixOS configuration (forwarded to home-manager).
    nixosArgs = {
      inherit inputs;
      nixos_secrets = inputs.nixos-secrets;
    };

    nixosConfigurations = {
      roo6 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = nixosArgs;
        modules = [./nodes/roo6];
      };

      marc-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = nixosArgs;
        modules = [./nodes/marc-laptop];
      };

      marc-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = nixosArgs;
        modules = [./nodes/marc-desktop];
      };
    };

    # Arguments shared by every home-manager config, mirroring the host
    # `specialArgs = { inherit inputs; }` passed through NixOS.
    hmExtraSpecialArgs = {
      inherit inputs;
      nixos_secrets = inputs.nixos-secrets;
    };

    # Allow unfree packages in standalone home-manager configs.
    hmCommonModule = {
      nixpkgs.config.allowUnfree = true;
    };

    # Standalone HM has no NixOS stylix module to forward the theme, so provide
    # it explicitly here (mirrors modules/stylix.nix on the NixOS side).
    # Yields a module definition (takes the system pkgs).
    hmStylixScheme = {
      pkgs,
      ...
    }: {
      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
      };
    };

    # Standalone home-manager configurations, extracted so deploy-rs can deploy
    # them independently of the NixOS `home-manager.users` integration.
    hmConfigurations = {
      "roo6.marc" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = hmExtraSpecialArgs;
        modules = [
          {
            home.username = "marc";
            home.homeDirectory = "/home/marc";
          }
          "${inputs.hm-config}/modules/ssh-zones.nix"
          "${inputs.hm-config}/profiles/core/default.nix"
          "${inputs.hm-config}/platforms/server.nix"
          hmCommonModule
          hmStylixScheme
          inputs.stylix.homeModules.stylix
        ];
      };

      "roo6.root" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = hmExtraSpecialArgs;
        modules = [
          {
            home.username = "root";
            home.homeDirectory = "/root";
          }
          "${inputs.hm-config}/modules/ssh-zones.nix"
          "${inputs.hm-config}/profiles/core/default.nix"
          "${inputs.hm-config}/platforms/server.nix"
          hmCommonModule
          hmStylixScheme
          inputs.stylix.homeModules.stylix
        ];
      };

      "marc-laptop.marc" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = hmExtraSpecialArgs;
        modules = [
          {
            home.username = "marc";
            home.homeDirectory = "/home/marc";
          }
          "${inputs.hm-config}/modules/ssh-zones.nix"
          "${inputs.hm-config}/modules/ssh-zones-config.nix"
          "${inputs.hm-config}/profiles/core/default.nix"
          "${inputs.hm-config}/profiles/desktop/default.nix"
          hmCommonModule
          hmStylixScheme
          inputs.stylix.homeModules.stylix
          inputs.niri.homeModules.niri
          inputs.sops-nix.homeManagerModules.sops
        ];
      };

      "marc-desktop.marc" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = hmExtraSpecialArgs;
        modules = [
          "${inputs.hm-config}/hosts/desktop-pc.nix"
          hmCommonModule
          hmStylixScheme
          inputs.stylix.homeModules.stylix
          inputs.niri.homeModules.niri
          inputs.sops-nix.homeManagerModules.sops
        ];
      };
    };

    deploy = {
      # Defaults shared by every node/profile (override priority: profile > node > deploy)
      sshUser = "marc";
      interactiveSudo = true;
      autoRollback = true;
      magicRollback = true;

      nodes = {
        roo6 = {
          hostname = "home";
          sshUser = "root";
          interactiveSudo = false;
          profiles = {
            system = {
              user = "root";
              path = (pkgsFor "aarch64-linux").deployPkgs.activate.nixos self.nixosConfigurations.roo6;
            };
            "home-marc" = {
              user = "marc";
              path = (pkgsFor "aarch64-linux").deployPkgs.activate.home-manager hmConfigurations."roo6.marc";
            };
            "home-root" = {
              user = "root";
              path = (pkgsFor "aarch64-linux").deployPkgs.activate.home-manager hmConfigurations."roo6.root";
            };
          };
          profilesOrder = ["system" "home-root" "home-marc"];
          groups = ["servers" "all"];
        };

        marc-laptop = {
          hostname = "marc-laptop";
          profiles = {
            system = {
              user = "root";
              path = (pkgsFor "x86_64-linux").deployPkgs.activate.nixos self.nixosConfigurations.marc-laptop;
            };
            "home-marc" = {
              user = "marc";
              path = (pkgsFor "x86_64-linux").deployPkgs.activate.home-manager hmConfigurations."marc-laptop.marc";
            };
          };
          profilesOrder = ["system" "home-marc"];
          groups = ["laptops" "all"];
        };

        marc-desktop = {
          hostname = "marc-desktop";
          profiles = {
            system = {
              user = "root";
              path = (pkgsFor "x86_64-linux").deployPkgs.activate.nixos self.nixosConfigurations.marc-desktop;
            };
            "home-marc" = {
              user = "marc";
              path = (pkgsFor "x86_64-linux").deployPkgs.activate.home-manager hmConfigurations."marc-desktop.marc";
            };
          };
          profilesOrder = ["system" "home-marc"];
          groups = ["desktops" "all"];
        };
      };
    };

    # Validate the deployment definitions on `nix flake check`.
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  in {
    inherit nixosConfigurations deploy checks;

    # Build the deploy-rs binary for `nix run .#deploy-rs`
    packages = {
      x86_64-linux.deploy-rs = deployRsPkg "x86_64-linux";
      aarch64-linux.deploy-rs = deployRsPkg "aarch64-linux";
    };

    apps = {
      x86_64-linux.deploy-rs = {
        type = "app";
        program = "${deployRsPkg "x86_64-linux"}/bin/deploy";
      };
      aarch64-linux.deploy-rs = {
        type = "app";
        program = "${deployRsPkg "aarch64-linux"}/bin/deploy";
      };
    };
  };
}