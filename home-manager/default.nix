{
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}:{
  imports = [
    ./gpg
    ./cli
  ] ++ lib.optionals(!pkgs.stdenv.isDarwin) [
    ./gui
    ./yubikey
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
