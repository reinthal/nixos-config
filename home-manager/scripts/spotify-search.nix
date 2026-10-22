{pkgs, ...}: let
  # CTRL+SHIFT+Space: fuzzel prompt -> Spotify artist search -> pick -> play
  # on the spotify-player daemon (cli/spotify-player.nix).
  #
  # Talks to the Web API directly instead of `spotify_player search`: in
  # 0.24.1 that subcommand fails with "missing field `popularity`" when a
  # custom client ID is in use. Reuses the Web API token spotify-player caches
  # (rspotify format); the daemon refreshes it hourly through its own calls.
  spotify-search = pkgs.writeShellApplication {
    name = "spotify-search";
    runtimeInputs = with pkgs; [fuzzel jq curl libnotify spotify-player coreutils];
    text = ''
      token_file="''${XDG_CACHE_HOME:-$HOME/.cache}/spotify-player/user_client_token.json"

      die() {
        notify-send -a spotify-search "Spotify search" "$1"
        exit 1
      }

      [ -r "$token_file" ] || die "No token. Run: spotify_player authenticate"

      query="$(fuzzel --dmenu --prompt-only "Spotify artist: " </dev/null)" || exit 0
      [ -n "$query" ] || exit 0

      # limit > 10 -> 400 "Invalid limit" for new (restricted quota) apps.
      search() {
        curl -s -G -w '\n%{http_code}' \
          -H "Authorization: Bearer $(jq -r .access_token "$token_file")" \
          "https://api.spotify.com/v1/search" \
          --data-urlencode "q=$query" \
          --data-urlencode "type=artist" \
          --data-urlencode "limit=10"
      }

      resp="$(search)"
      code="''${resp##*$'\n'}"
      if [ "$code" = "401" ]; then
        # Expired token: any API call through the running instance refreshes
        # the cache file. Then retry once.
        spotify_player get key playback >/dev/null 2>&1 || true
        resp="$(search)"
        code="''${resp##*$'\n'}"
      fi
      body="''${resp%$'\n'*}"
      [ "$code" = "200" ] || die "Spotify API HTTP $code: $(jq -r .error.message <<<"$body" 2>/dev/null)"

      # Artist names for display; index maps back to the id. (genres are empty
      # for restricted-quota apps, so not shown.)
      mapfile -t ids < <(jq -r '.artists.items[].id' <<<"$body")
      [ "''${#ids[@]}" -gt 0 ] || die "No artists found for \"$query\""

      idx="$(jq -r '.artists.items[].name' <<<"$body" \
        | fuzzel --dmenu --index --prompt "Artist: " --lines 10)" || exit 0
      [ -n "$idx" ] || exit 0

      spotify_player playback start context --id "''${ids[$idx]}" artist \
        || die "Could not start playback (daemon running?)"
    '';
  };
in {
  home.packages = [spotify-search];
}
