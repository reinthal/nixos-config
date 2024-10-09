{
  pkgs,
  inputs,
  ...
}: let
  pyprland = inputs.pyprland.packages.${pkgs.system}.pyprland;
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    export XKB_DEFAULT_LAYOUT=us
    export XCURSOR_THEME=Qogir
    ags -b hypr
    hyprctl setcursor Qogir 24
    ${pyprland}/bin/pypr
  '';
in {
  home.packages = [startupScript];
}
