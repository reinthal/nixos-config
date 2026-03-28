{pkgs, ...}: let
  khal-notify = pkgs.writeShellScriptBin "khal-notify" ''
    STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/khal-notify"
    STATE_FILE="$STATE_DIR/notified"
    mkdir -p "$STATE_DIR"
    touch "$STATE_FILE"

    # Clean state file: remove entries older than 1 day
    find "$STATE_FILE" -mtime +1 -exec truncate -s 0 {} \;

    # Get events in the next 15 minutes
    ${pkgs.khal}/bin/khal list now 15m --format "{start-time} - {end-time} | {title} | {location}" 2>/dev/null | while IFS= read -r line; do
      # Skip date headers and empty lines
      [[ -z "$line" ]] && continue
      [[ "$line" =~ ^[A-Z][a-z]+,\  ]] && continue
      [[ "$line" =~ ^Today, ]] && continue
      [[ "$line" =~ ^Tomorrow, ]] && continue
      [[ "$line" == "No events" ]] && continue

      # Deduplicate using hash of event line
      hash=$(echo "$line" | md5sum | cut -d' ' -f1)
      if grep -qF "$hash" "$STATE_FILE" 2>/dev/null; then
        continue
      fi

      # Parse fields: "time | title | location"
      time=$(echo "$line" | cut -d'|' -f1 | sed 's/^ *//;s/ *$//')
      title=$(echo "$line" | cut -d'|' -f2 | sed 's/^ *//;s/ *$//')
      location=$(echo "$line" | cut -d'|' -f3 | sed 's/^ *//;s/ *$//')

      body="$time"
      if [[ -n "$location" ]]; then
        body="$time
$location"
      fi

      ${pkgs.libnotify}/bin/notify-send -u normal -a "khal" "$title" "$body"
      echo "$hash" >> "$STATE_FILE"
    done
  '';
in {
  home.packages = [khal-notify];

  systemd.user.services.khal-notify = {
    Unit = {
      Description = "khal calendar event notifications";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${khal-notify}/bin/khal-notify";
    };
  };

  systemd.user.timers.khal-notify = {
    Unit = {
      Description = "Run khal-notify every 5 minutes";
    };
    Timer = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };
}
