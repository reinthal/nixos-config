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

    ags = prev.ags.overrideAttrs (oldAttrs: rec {
      buildInputs = oldAttrs.buildInputs ++ [pkgs.libdbusmenu-gtk3];
    });
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
  pkgs.overlays = [inputs.nix-firefox-addons.overlays.default];
}
