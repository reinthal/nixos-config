{
  pkgs,
  lib,
  ...
}: {
  imports = [./cli];

  programs.git.signing = {
    signByDefault = lib.mkForce false;
    key = lib.mkForce null;
  };

  home.sessionVariables = {
    # On non-NixOS (Lambda/Ubuntu), NVIDIA libs live in system paths.
    # Point Nix tools (devenv, nix-shell) to the driver libs.
    LD_LIBRARY_PATH = lib.makeSearchPath "lib" [
      "/run/opengl-driver"
      "/usr/lib/x86_64-linux-gnu"
    ];
    CUDA_PATH = "/usr/local/cuda";
  };

  home.sessionPath = [
    "/usr/local/cuda/bin"
  ];
}
