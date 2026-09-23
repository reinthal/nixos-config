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

  # Package modifications (patches, version changes, per-platform fixes).
  modifications = final: prev: {
    # nixpkgs ships a single node_modules FOD hash computed on x86_64, so on
    # aarch64 the x64-only native deps get reused and the build can't resolve
    # @opentui/core-linux-arm64. Give aarch64-linux its own hash.
    cyberstrike = prev.cyberstrike.overrideAttrs (old: {
      node_modules = old.node_modules.overrideAttrs (nmOld: {
        outputHash =
          if prev.stdenv.hostPlatform.system == "aarch64-linux"
          then "sha256-cixPB97YgEDuohCci38ZdjXfvTqCs3ihNIlRt4Go5RU="
          else nmOld.outputHash;
      });
    });
  };
}
