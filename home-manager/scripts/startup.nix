{
  pkgs,
  inputs,
  ...
}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    export XKB_DEFAULT_LAYOUT=us
    export XCURSOR_THEME=Qogir
    ${pkgs.hyprland}/bin/hyprctl setcursor Qogir 24

  '';
in {
  home.packages = [startupScript];
}
