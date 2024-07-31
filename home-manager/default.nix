{
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}:{
  imports = [
    ./crypto
    ./cli
  ] ++ lib.optionals(!pkgs.stdenv.isDarwin) [
    ./waybar
    ./hyprlock.nix
    ./hyprland.nix
    ./theme.nix
     (import ./gui {inherit lib pkgs;})
  ];
  nixpkgs = {
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
  # Don"t change this when you change package input. Leave it alone.
  home = {
    stateVersion = "24.05";
    # specify my home-manager configs
    packages = with pkgs; [];
  };
    
}
