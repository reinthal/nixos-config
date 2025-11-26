{pkgs, ...}: let
  mako-waybar = pkgs.writeShellScriptBin "mako-waybar" ''
    # Get notification list from mako
    output=$(${pkgs.mako}/bin/makoctl list 2>&1)
    exit_code=$?

    # Check if makoctl succeeded
    if [ $exit_code -ne 0 ]; then
        printf '{"alt":"none","tooltip":"Mako not running"}'
        exit 0
    fi

    # Count notifications by counting lines that start with "Notification"
    count=$(echo "$output" | ${pkgs.gnugrep}/bin/grep -c "^Notification" || echo "0")

    # Output for waybar
    if [ "$count" -gt 0 ]; then
        printf '{"alt":"notification","tooltip":"%s notification(s)"}' "$count"
    else
        printf '{"alt":"none","tooltip":"No notifications"}'
    fi
  '';
in {
  home.packages = [mako-waybar];
}
