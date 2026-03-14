{
  pkgs,
  lib,
  outputs,
  stateVersion,
  inputs,
  config,
  ...
}: {
  imports = [
    ./cli/openclaw.nix
    ./email
    (import ./sops.nix {inherit inputs config; secretsFile = ../secrets/shared.yaml;})
  ];

  services.gnome-keyring.enable = true;
  services.protonmail-bridge.enable = true;

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
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
