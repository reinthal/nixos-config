{pkgs, ...}: let
  toggle-scratchpad =
    pkgs.writeShellScriptBin "toggle-scratchpad"
    ''
            IS_SCRATCHPAD=$(${pkgs.hyprland}/bin/hyprctl activewindow | awk 'NR==6 {print $3}' | grep "special:scratchpad")

            if [  $IS_SCRATCHPAD ]; then
      ${pkgs.hyprland}/bin/hyprctl dispatch togglespecialworkspace
            else
               scratchpad -t
            fi
    '';
in {
  home.packages = [toggle-scratchpad];
}
