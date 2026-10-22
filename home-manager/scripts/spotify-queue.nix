{pkgs, ...}: let
  # SUPER+SHIFT+Space: browse the spotify-player queue in fuzzel and jump to a
  # track. Jumps by issuing `playback next` N times so the current context and
  # the rest of the queue survive (`playback start track` would replace both).
  spotify-queue = pkgs.writeShellApplication {
    name = "spotify-queue";
    runtimeInputs = with pkgs; [fuzzel jq libnotify spotify-player coreutils];
    text = ''
      die() {
        notify-send -a spotify-queue "Spotify queue" "$1"
        exit 1
      }

      queue="$(spotify_player get key queue 2>/dev/null)" || die "Daemon not reachable"
      [ -n "$queue" ] || die "Empty queue"

      # Line 0 = currently playing, lines 1.. = upcoming.
      lines="$(jq -r '
        def fmt: "\(.name) — \([.artists[].name] | join(", "))";
        (if .currently_playing then "▶ " + (.currently_playing | fmt) else "▶ (nothing playing)" end),
        (.queue[] | "   " + fmt)
      ' <<<"$queue")"
      n="$(wc -l <<<"$lines")"
      [ "$n" -gt 1 ] || die "Queue is empty"

      idx="$(fuzzel --dmenu --index --prompt "Queue: " --lines 15 <<<"$lines")" || exit 0
      [ -n "$idx" ] && [ "$idx" -gt 0 ] || exit 0

      for _ in $(seq "$idx"); do
        spotify_player playback next >/dev/null || die "Skip failed"
      done
    '';
  };
in {
  home.packages = [spotify-queue];
}
