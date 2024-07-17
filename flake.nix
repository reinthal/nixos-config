{
  description = "Alex config flake";

  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11
    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Controls system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    apple-silicon.url = "github:tpwrules/nixos-apple-silicon";

    # Tricked out nvim :)
    pwnvim.url = "github:zmre/pwnvim";
    
    # TODO
    # nix-colors.url = "github:misterio77/nix-colors";
    # firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    # 
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    pwnvim,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
      
     nixosConfigurations = {
      # FIXME replace with your hostname
      nixbook = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        # > Our main nixos configuration file <
        modules = [./nixos/hosts/nixbook];
      };
    };
     
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
            extraSpecialArgs = {inherit pwnvim;};
            users.kog.imports = [
              ./home-manager
            ];
          };
        }
      ];
    };
  };
}

