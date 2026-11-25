{
  writeShellApplication,
  coreutils,
  findutils,
  gnugrep,
  gnused,
  util-linux,
  fuzzel,
}:
# Draws the SUPER + Tab window list for wm.switch in home-manager/hyprland/
# wm.lua, which owns the state (hold SUPER, Tab to move, release to focus).
#
#   hyprland-window-switcher SEQ show GEN INDEX   draw switch GEN, INDEX selected
#   hyprland-window-switcher SEQ hide             close the list
#
# wm.lua writes the windows (workspace, class, title per line, most recently
# focused first) to $XDG_RUNTIME_DIR/hyprland-window-switcher.tsv. fuzzel cannot
# move its selection from outside, so every Tab relaunches it. SEQ grows with
# every call; a call older than the last one drawn is dropped. hyprctl comes
# from the session PATH so it matches the running compositor.
writeShellApplication {
  name = "hyprland-window-switcher";
  runtimeInputs = [coreutils findutils gnugrep gnused util-linux fuzzel];
  text = ''
    base=''${XDG_RUNTIME_DIR:-/tmp}/hyprland-window-switcher
    n=$1 cmd=$2

    exec 9> "$base.lock"
    flock 9
    last=$(cat "$base.seq" 2> /dev/null || echo 0)
    [ "$n" -gt "$last" ] || exit 0
    echo "$n" > "$base.seq"

    # Close the list drawn by the previous call.
    if pid=$(cat "$base.pid" 2> /dev/null); then
      rm -f "$base.pid"
      if kill "$pid" 2> /dev/null; then
        for _ in $(seq 50); do kill -0 "$pid" 2> /dev/null || break; sleep 0.01; done
      fi
    fi
    [ "$cmd" = show ] || exit 0
    gen=$3 index=$4

    # Icon name for a window class, from its .desktop file when one exists.
    icon_for() {
      local class=$1 file="" dir icon=""
      IFS=: read -ra dirs <<< "''${XDG_DATA_DIRS:-/run/current-system/sw/share}:''${XDG_DATA_HOME:-$HOME/.local/share}"
      for dir in "''${dirs[@]}"; do
        [ -d "$dir/applications" ] || continue
        file=$(find -L "$dir/applications" -maxdepth 1 -iname "$class.desktop" -print -quit 2> /dev/null)
        [ -n "$file" ] || file=$(grep -rilx -m1 "StartupWMClass=$class" "$dir/applications" 2> /dev/null | head -n1 || true)
        [ -n "$file" ] && break
      done
      [ -n "$file" ] && icon=$(sed -n 's/^Icon=//p' "$file" | head -n1)
      printf '%s' "''${icon:-''${class,,}}"
    }

    # The fuzzel input, built once per switch: "<ws> <class> — <title>\0icon\x1f<icon>".
    if [ "$(cat "$base.gen" 2> /dev/null)" != "$gen" ]; then
      declare -A icons
      while IFS=$'\t' read -r ws class title; do
        [ -n "''${icons[$class]+x}" ] || icons[$class]=$(icon_for "$class")
        printf '%-3s %s  —  %s\0icon\x1f%s\n' "$ws" "$class" "$title" "''${icons[$class]}"
      done < "$base.tsv" > "$base.menu"
      echo "$gen" > "$base.gen"
    fi
    count=$(wc -l < "$base.menu")

    # on-demand keyboard focus: keys stay with Hyprland's switcher submap and
    # the focused window; a mouse click on an entry still picks it.
    out=$(mktemp)
    fuzzel --dmenu --index --only-match --namespace hyprland-window-switcher \
      --keyboard-focus=on-demand --no-exit-on-keyboard-focus-loss \
      --prompt "Windows: " --width=80 --lines="$((count < 15 ? count : 15))" \
      --select-index="$index" < "$base.menu" > "$out" 9>&- &
    echo $! > "$base.pid"
    flock -u 9
    exec 9>&-

    status=0
    wait $! || status=$?
    picked=$(cat "$out")
    rm -f "$out"
    if [ "$status" -eq 0 ] && [ -n "$picked" ] && [ "$picked" -ge 0 ]; then
      hyprctl eval "wm.switch_pick($gen, $picked)" > /dev/null
    fi
  '';
}
