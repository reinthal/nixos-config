{pkgs, ...}: let
  toggle-scratchpad =
    pkgs.writeShellScriptBin "toggle-scratchpad"
    ''
      IS_SCRATCHPAD=$(${pkgs.hyprland}/bin/hyprctl activewindow | awk 'NR==6 {print $3}' | grep "special:scratchpad")

      if [  $IS_SCRATCHPAD ]; then
         scratchpad -t
      else
         ${pkgs.hyprland}/bin/hyprctl dispatch togglespecialworkspace
      fi
    '';
in {
  home.packages = [toggle-scratchpad];
}
