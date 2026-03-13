{
  description = "Alex config flake";
  nixConfig = {
    substituters = [
      "https://minio.nas.reinthal.me/nix-cache"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "minio.nas.reinthal.me-1:snkldWl4cS1qcKxjNyHX+wTtOAv/hpT5SITsYlzKFUA="
    ];
  };
  inputs = {
    zen-browser.url = "github:reinthal/zen-browser-flake";
    sops-nix.url = "github:Mic92/sops-nix";
    pyprland.url = "github:hyprland-community/pyprland";
    pyprland.inputs.nixpkgs.follows = "nixpkgs";
    claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    reinthalVim = {
      url = "github:reinthal/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    apple-silicon.url = "github:nix-community/nixos-apple-silicon/linux-6-18";
    apple-silicon.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    ...
  } @ inputs: let
    inherit (self) outputs;
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  in rec
  {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./pkgs {inherit pkgs;}
    );

    nixosConfigurations = {
      workstation = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit nixpkgs self inputs outputs;};
        modules = [./nixos/hosts/workstation];
      };
      seed = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit nixpkgs self inputs outputs;};
        modules = [./nixos/hosts/seed];
      };

      build = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit nixpkgs self inputs outputs;};
        modules = [./nixos/hosts/build];
      };
      relay = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit nixpkgs self inputs outputs;};
        # > Our main nixos configuration file <
        modules = [./nixos/hosts/relay];
      };
      flix = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit nixpkgs self inputs outputs;};
        modules = [./nixos/hosts/flix];
      };
      nixbook = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit nixpkgs self inputs outputs;};
        # > Our main nixos configuration file <
        modules = [./nixos/hosts/nixbook];
      };
    };

    # Your custom packages and modifications, exported as overlays
    overlays = let
      pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
    in
      import ./overlays {inherit pkgs inputs;}
      // {
      };

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    darwinConfigurations.mbp = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
      modules = [
        ./darwin
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useUserPackages = true;
            backupFileExtension = "hm-bkp";
            extraSpecialArgs = {
              inherit nixpkgs inputs outputs;
              stateVersion = "24.11";
            };
            users.kog.imports = [
              ./home-manager/darwin.nix
            ];
          };
        }
      ];
    };

    # Standalone home-manager configurations
    homeConfigurations = {
      "kog@cli" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [
            outputs.overlays.unstable-packages
            outputs.overlays.additions
            outputs.overlays.modifications
          ];
        };
        extraSpecialArgs = {
          inherit nixpkgs inputs outputs;
          stateVersion = "25.11";
        };
        modules = [
          ./home-manager/cli/default.nix
          {
            home.username = builtins.getEnv "USER";
            home.homeDirectory = /. + (builtins.getEnv "HOME");
          }
        ];
      };
      "claw@cli" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = [
            outputs.overlays.unstable-packages
            outputs.overlays.additions
            outputs.overlays.modifications
          ];
        };
        extraSpecialArgs = {
          inherit nixpkgs inputs outputs;
          stateVersion = "25.11";
        };
        modules = [
          ./home-manager/cli/openclaw.nix
          {
            home.username = "claw";
            home.homeDirectory = "/home/claw";
          }
        ];
      };
    };
  };
}
