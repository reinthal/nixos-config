{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    
    hyprland-hyprspace = {
      url = "github:KZDKM/Hyprspace";
      inputs.hyprland.follows = "hyprland";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matugen.url = "github:InioX/matugen?ref=v2.2.0";
      ags.url = "github:Aylur/ags";
      astal.url = "github:Aylur/astal";

      lf-icons = {
        url = "github:gokcehan/lf";
        flake = false;
      };

      firefox-gnome-theme = {
        url = "github:rafaelmardojai/firefox-gnome-theme";
        flake = false;
      };

  };

   

  outputs = { self, nixpkgs, ... } @inputs: {
    nixosConfigurations = {
      
      default = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [
          ./hosts/default/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };

      build = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [
          ./hosts/build/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}