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
    ./email
    ./terminal
    ./yubikey
    ./scripts
    ./hyprland
    ./theme.nix
    ./sops.nix
    (import ./gui {inherit lib pkgs;})
  ];

  services = {
    gnome-keyring.enable = true;
  };

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
