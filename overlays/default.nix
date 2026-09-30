# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: super: {
    # nest everything under a namespace that's not likely to collide
    # with anything in nixpkgs
    local-pkgs = import ../pkgs {pkgs = final;};
  };

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

  # Swap the nixos-apple-silicon kernel for the upstream "fairydust" branch
  # (USB-C DisplayPort alt-mode). nixos-apple-silicon applies its own overlay
  # with mkBefore and reads `linux-asahi` from the final package set, so
  # overriding the attribute here is enough for boot.kernelPackages to follow.
  # Apply only on Asahi hosts (see nixos/hosts/nixbook).
  asahi-fairydust = final: _prev: {
    linux-asahi = final.callPackage ../pkgs/linux-asahi-fairydust {};
  };

  # Package modifications (patches, version changes, per-platform fixes).
  modifications = final: prev: {
    # cyberstrike removed: the nixpkgs package is broken. Installed via
    # `bun add -g @cyberstrike-io/cyberstrike@latest` in
    # scripts/bootstrap-home-manager.sh instead.
  };
}
