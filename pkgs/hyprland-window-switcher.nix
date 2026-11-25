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
# move its selection from outside, so every Tab relaunches it (new one up
# before the old one closes, so it does not flash). SEQ grows with
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

    # The list drawn by the previous call. On show it is closed only once the
    # new one is on screen, so there is no empty frame between the two.
    old="" old_slot=1
    read -r old old_slot 2> /dev/null < "$base.pid" || true
    rm -f "$base.pid"
    close_old() {
      [ -n "$old" ] && kill "$old" 2> /dev/null || true
    }
    if [ "$cmd" != show ]; then
      close_old
      exit 0
    fi
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

    # on-demand keyboard focus: keys stay with Hyprland's switcher submap;
    # Enter or a click on an entry still picks it.
    # fuzzel allows one instance per $XDG_RUNTIME_DIR/fuzzel-$WAYLAND_DISPLAY.lock.
    # To have the new list up before the old one closes, alternate between two
    # runtime dirs that each link to the real Wayland socket.
    slot=$((1 - old_slot))
    rt=$base.slot$slot
    mkdir -p "$rt"
    ln -sfn "''${XDG_RUNTIME_DIR:-/tmp}/''${WAYLAND_DISPLAY:-wayland-0}" "$rt/''${WAYLAND_DISPLAY:-wayland-0}"

    out=$(mktemp)
    XDG_RUNTIME_DIR=$rt fuzzel --dmenu --index --only-match --namespace hyprland-window-switcher \
      --keyboard-focus=on-demand --no-exit-on-keyboard-focus-loss \
      --prompt "Windows: " --width=80 --lines="$((count < 15 ? count : 15))" \
      --select-index="$index" < "$base.menu" > "$out" 9>&- &
    pid=$!
    echo "$pid $slot" > "$base.pid"
    if [ -n "$old" ]; then
      for _ in $(seq 30); do
        hyprctl layers -j 2> /dev/null | grep -q "\"pid\": $pid\b" && break
        sleep 0.01
      done
    fi
    close_old
    flock -u 9
    exec 9>&-

    status=0
    wait "$pid" || status=$?
    picked=$(cat "$out")
    rm -f "$out"
    if [ "$status" -eq 0 ] && [ -n "$picked" ] && [ "$picked" -ge 0 ]; then
      hyprctl eval "wm.switch_pick($gen, $picked)" > /dev/null
    fi
  '';
}
