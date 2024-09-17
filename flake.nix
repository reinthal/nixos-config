{
  description = "Alex config flake";

  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    sops-nix.url = "github:Mic92/sops-nix";
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/1284004bf6c6e50d8592b6efe83708931e75aec7"; # nixpkgs-unstable nixos-22.11
    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    jordanVim.url = "github:jordanisaacs/neovim-flake";
    #
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    ags.url = "github:Aylur/ags";
    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
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
    # Your custom packages
    # Acessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./pkgs {inherit pkgs;}
    );
    nixosConfigurations = {
      build = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit nixpkgs self inputs outputs;};
        modules = [./nixos/hosts/build];
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
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-bkp";
            users.kog.imports = [
              ./home-manager
            ];
          };
        }
      ];
    };
  };
}
