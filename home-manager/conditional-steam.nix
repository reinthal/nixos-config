{
  pkgs,
  lib,
  ...
}: {
  imports = lib.optionals (pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86_64) [
    ./steam
  ];
}
