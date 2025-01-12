{
  pkgs,
  inputs,
  ...
}: let
  trim-generations  = pkgs.pkgs.writeShellScriptBin "start" ''

  '';
in {
  home.packages = [trim-generations];
}
