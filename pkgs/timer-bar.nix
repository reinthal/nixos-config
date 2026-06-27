# Timer bar for waybar.
#
# Renders a countdown progress bar as a waybar `custom/timer` module and drives
# it from a small daemon. Two modes, picked from a fuzzel menu:
#   - simple:   one countdown of a chosen length
#   - pomodoro: alternating work/rest phases, looping until stopped
#
# Work/rest lengths are configured here (callPackage args in pkgs/default.nix)
# and can be overridden per-invocation with the TIMER_WORK_MIN / TIMER_REST_MIN
# environment variables.
{
  writeShellApplication,
  fuzzel,
  libnotify,
  coreutils,
  procps,
  gawk,
  workMinutes ? 30,
  restMinutes ? 10,
}:
writeShellApplication {
  name = "timer-bar";
  runtimeInputs = [fuzzel libnotify coreutils procps gawk];
  text = ''
    # Defaults baked from nix, overridable via environment.
    WORK_MIN="''${TIMER_WORK_MIN:-${toString workMinutes}}"
    REST_MIN="''${TIMER_REST_MIN:-${toString restMinutes}}"

    STATE_DIR="''${XDG_RUNTIME_DIR:-/tmp}/timer-bar"
    STATE="$STATE_DIR/state"
    PIDF="$STATE_DIR/daemon.pid"
    mkdir -p "$STATE_DIR"

    # state line format: label|phase|end_epoch|total_seconds
    write_state() {
      printf '%s|%s|%s|%s\n' "$1" "$2" "$3" "$4" > "$STATE"
    }

    clear_state() { rm -f "$STATE"; }

    stop_daemon() {
      if [ -f "$PIDF" ]; then
        pid="$(cat "$PIDF")"
        # daemon runs in its own session; kill the whole process group.
        kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
        rm -f "$PIDF"
      fi
      clear_state
    }

    start_daemon() {
      stop_daemon
      setsid "$0" daemon "$@" >/dev/null 2>&1 &
      echo $! > "$PIDF"
    }

    notify() { notify-send -a "Timer" "$1" "$2"; }

    # ---- daemon: runs detached, manages phases ----
    run_simple() {
      mins="$1"
      total=$((mins * 60))
      end=$(( $(date +%s) + total ))
      write_state "Timer" "timer" "$end" "$total"
      sleep "$total"
      notify "Timer done" "$mins min elapsed."
      clear_state
    }

    run_pomodoro() {
      work="$1"
      rest="$2"
      while true; do
        total=$((work * 60))
        end=$(( $(date +%s) + total ))
        write_state "Work" "work" "$end" "$total"
        sleep "$total"
        notify "Work done" "Break for $rest min."

        total=$((rest * 60))
        end=$(( $(date +%s) + total ))
        write_state "Rest" "rest" "$end" "$total"
        sleep "$total"
        notify "Break over" "Back to work for $work min."
      done
    }

    daemon() {
      trap 'clear_state; exit 0' TERM INT
      case "$1" in
        simple) run_simple "$2" ;;
        pomodoro) run_pomodoro "$2" "$3" ;;
      esac
    }

    # ---- status: emit one JSON line for waybar ----
    status() {
      if [ ! -f "$STATE" ]; then
        echo ""
        return
      fi
      IFS='|' read -r label phase end total < "$STATE"
      now="$(date +%s)"
      rem=$((end - now))
      [ "$rem" -lt 0 ] && rem=0

      cells=10
      if [ "$total" -le 0 ]; then
        filled=0
        frac=0
      else
        filled="$(awk -v r="$rem" -v t="$total" -v c="$cells" 'BEGIN{printf "%d", (r/t)*c + 0.5}')"
        frac="$(awk -v r="$rem" -v t="$total" 'BEGIN{printf "%d", (r/t)*100}')"
      fi
      [ "$filled" -gt "$cells" ] && filled="$cells"

      bar=""
      i=0
      while [ "$i" -lt "$cells" ]; do
        if [ "$i" -lt "$filled" ]; then bar="$bar▰"; else bar="$bar▱"; fi
        i=$((i + 1))
      done

      case "$phase" in
        work) icon="🍅" ;;
        rest) icon="☕" ;;
        *) icon="⏳" ;;
      esac

      mm=$((rem / 60))
      ss=$((rem % 60))
      printf '{"text":"%s %s %d:%02d","tooltip":"%s — %d:%02d left","percentage":%d,"class":"%s"}\n' \
        "$icon" "$bar" "$mm" "$ss" "$label" "$mm" "$ss" "$frac" "$phase"
    }

    # Prompt for minutes via fuzzel. Presets shown; typing any number works too
    # (fuzzel --dmenu returns the typed text). Default preset listed first.
    # Echoes a positive integer on success, nothing on cancel/invalid.
    prompt_minutes() {
      prompt="$1"
      default="$2"
      mins="$(printf '%s\n5\n10\n15\n25\n45\n' "$default" \
        | fuzzel --dmenu --prompt "$prompt" --placeholder "preset or type minutes" --lines=6)"
      mins="''${mins//[[:space:]]/}"
      if [ -n "$mins" ] && [ "$mins" -gt 0 ] 2>/dev/null; then
        echo "$mins"
      elif [ -n "$mins" ]; then
        notify "Timer" "Invalid minutes: $mins"
      fi
    }

    # ---- menu: fuzzel picker ----
    menu() {
      choice="$(printf 'Pomodoro (%s/%s min)\nSimple\nStop\n' "$WORK_MIN" "$REST_MIN" \
        | fuzzel --dmenu --prompt "Timer: " --lines=3)"
      case "$choice" in
        Pomodoro*)
          work="$(prompt_minutes "Work min: " "$WORK_MIN")"
          [ -n "$work" ] || exit 0
          rest="$(prompt_minutes "Rest min: " "$REST_MIN")"
          [ -n "$rest" ] || exit 0
          start_daemon pomodoro "$work" "$rest"
          ;;
        Simple)
          mins="$(prompt_minutes "Minutes: " 25)"
          [ -n "$mins" ] && start_daemon simple "$mins"
          ;;
        Stop) stop_daemon ;;
      esac
    }

    case "''${1:-menu}" in
      menu) menu ;;
      status) status ;;
      stop) stop_daemon ;;
      daemon) shift; daemon "$@" ;;
      *) echo "usage: timer-bar [menu|status|stop]" >&2; exit 1 ;;
    esac
  '';
}
