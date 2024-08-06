{pkgs, ...}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    export XKB_DEFAULT_LAYOUT=us
    export XCURSOR_THEME=Qogir
    ags -b hypr
    hyprctl setcursor Qogir 24
  '';
in {
  home.packages = [startupScript];
}

