{pkgs, ...}: let
  toggle-scratchpad = pkgs.writeShellScriptBin "toggle-scratchpad" ''
    IS_SCRATCHPAD=$(${pkgs.hyprland}/bin/hyprctl activewindow | awk 'NR==6 {print $3}' | grep "special:scratchpad")
    if echo "$output" | grep -q "special:scratchpad"; then
    echo "The output contains 'special:scratchpad'"
else
    echo "The output does not contain 'special:scratchpad'"
fi  '';
in {
  home.packages = [toggle-scratchpad];
}
