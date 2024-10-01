{pkgs, ...}: let
  hdrop = "${pkgs.hdrop}/bin/hdrop";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl}";
  toggle-scratchpad =
    pkgs.writeShellScriptBin "toggle-scratchpad"
    ''
            IS_SCRATCHPAD=$(${hyprctl} activewindow | awk 'NR==6 {print $3}' | grep "special:scratchpad")


            if [  $IS_SCRATCHPAD ]; then
            # This is a hack, cant figure out how to do this programatically
            ${hdrop} kitty -c __scratchpadtoggler
            ${hdrop} kitty -c __scratchpadtoggler
      ${pkgs.hyprland}/bin/hyprctl dispatch togglespecialworkspace
            else
               scratchpad -t
            fi
    '';
in {
  home.packages = [toggle-scratchpad];
}
