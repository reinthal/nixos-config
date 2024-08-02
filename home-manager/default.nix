{
  pkgs,
  lib,
  ...
}: let
  # builtins.currentSystem makes the flake impure, see https://nix.dev/manual/nix/2.23/command-ref/conf-file#conf-pure-eval
  isMacOS = builtins.currentSystem == "aarch64-darwin";
in {
  imports =
    [
      ./gpg
      ./cli
    ]
    ++ lib.optionals (!isMacOS) [
      ./gui
      ./terminal
      ./yubikey
      ./waybar
      ./scripts
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
  };
}
