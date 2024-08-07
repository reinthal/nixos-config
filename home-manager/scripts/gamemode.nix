{pkgs, ...}: let
  gamemode = pkgs.writeShellScriptBin "gamemode" ''
    HYPRGAMEMODE=$(${pkgs.hyprland}/bin/hyprctl getoption animations:enabled | awk 'NR==1{print $2}')
    if [ "$HYPRGAMEMODE" = 1 ] ; then
        ${pkgs.hyprland}/bin/hyprctl --batch "\
            keyword animations:enabled 0;\
            keyword decoration:drop_shadow 0;\
            keyword decoration:blur:enabled 0;\
            keyword decoration:active_opacity 1.0;\
            keyword decoration:inactive_opacity 1.0;\
            keyword general:gaps_in 0;\
            keyword general:gaps_out 0;\
            keyword general:border_size 1;\
            keyword decoration:rounding 0"
        exit
    fi
    ${pkgs.hyprland}/bin/hyprctl reload
  '';
in {
  home.packages = [gamemode];
}