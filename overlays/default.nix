# This file defines overlays
{
  pkgs,
  inputs,
  ...
}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: super: {
    # nest everything under a namespace that's not likely to collide
    # with anything in nixpkgs
    local-pkgs = import ../pkgs {pkgs = final;};
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    # Mesa patch for Firefox regression fix (Apple Silicon)
    # Uses specific nixpkgs commit with working Mesa 25.3.0
    mesa =
      if prev.mesa.version == "25.3.0"
      then
        (import (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/c5ae371f1a6a7fd27823bc500d9390b38c05fa55.tar.gz";
          sha256 = "sha256-4PqRErxfe+2toFJFgcRKZ0UI9NSIOJa+7RXVtBhy4KE=";
        }) {
          localSystem = final.stdenv.hostPlatform;
        })
        .mesa
      else prev.mesa;
  };
  master-packages = final: _prev: {
    master = import inputs.nixpkgs-master {
      system = final.system;
      config.allowunfree = true;
    };
  };
  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
