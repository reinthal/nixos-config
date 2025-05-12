{
  pkgs,
  lib,
  outputs,
  stateVersion,
  ...
}: {
  imports = [
    ./gpg
    ./cli
    ./terminal
  ];

  nixpkgs = {
    overlays = [
    ];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };
  # Don"t change this when you change package input. Leave it alone.
  home = {
    stateVersion = stateVersion;
  };
}
