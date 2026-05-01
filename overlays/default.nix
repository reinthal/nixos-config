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
  #modifications = final: prev: {
  # example = prev.example.overrideAttrs (oldAttrs: rec {
  # ...
  # });

  # When applied, the nixpkgs-unstable set (same branch as the main nixpkgs,
  # but independently pinned) will be accessible through 'pkgs.unstable'.
  # Use pkgs.unstable.<name> for packages that should update more frequently
  # than the rest of the system (e.g. fast-moving tools like claude-code, devenv).
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # When applied, the nixpkgs master branch will be accessible through 'pkgs.master'.
  # Use pkgs.master.<name> for bleeding-edge packages from the master branch.
  master-packages = final: _prev: {
    master = import inputs.nixpkgs-master {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
