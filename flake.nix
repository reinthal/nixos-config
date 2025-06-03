{
  description = "Alex config flake";

  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    zen-browser.url = "github:reinthal/zen-browser-flake";
    sops-nix.url = "github:Mic92/sops-nix";
    pyprland.url = "github:hyprland-community/pyprland";
    pyprland.inputs.nixpkgs.follows = "nixpkgs";
    claude-desktop.url = "github:k3d3/claude-desktop-linux-flake";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    marble = {
      url = "github:reinthal/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    reinthalVim = {
      url = "github:reinthal/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # called derivations that say how to build software.
    nixpkgs.url = "github:NixOS/nixpkgs/25.05";
    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    apple-silicon.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    # marble,
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
    # Your custom packages
    # Acessible through 'nix build', 'nix shell', etc
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
      import ./overlays {inherit pkgs inputs;};

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
  };
}
