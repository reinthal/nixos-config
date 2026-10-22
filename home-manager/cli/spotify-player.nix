{
  config,
  pkgs,
  ...
}: {
  # Terminal Spotify client (librespot-based). Audio via ALSA default -> PipeWire.
  # First run: `spotify_player authenticate` opens a browser for OAuth; tokens
  # cached under $XDG_CACHE_HOME/spotify-player. Binary is `spotify_player`.
  # Docs: https://github.com/aome510/spotify-player/blob/master/docs/config.md
  programs.spotify-player = {
    enable = true;

    # $XDG_CONFIG_HOME/spotify-player/app.toml
    settings = {
      # Own Spotify app client ID. Default (shared ncspot ID) is rate limited:
      # every launch got instant 429s on /me/playlists etc. -> endless "Loading".
      # Register at https://developer.spotify.com/dashboard with redirect URI
      # http://127.0.0.1:8989/login (loopback IP, not localhost), store ID under
      # spotify/client_id in shhh.yaml, then run `spotify_player authenticate`.
      # Must be the {command, args} table form; a plain string parses as None.
      client_id_command = {
        command = "cat";
        args = [config.sops.secrets."spotify/client_id".path];
      };
      theme = "default";
      border_type = "Rounded";
      progress_bar_type = "Line";
      enable_notify = true;
      notify_transient = true;
      enable_cover_image_cache = true;
      cover_img_width = 5;
      playback_format = "{status} {track} • {artists} {liked}\n{album} • {genres}\n{metadata}";
      # Only the systemd daemon below streams audio and registers as the
      # Spotify Connect device; the TUI and `spotify_player` CLI just control it.
      enable_streaming = "DaemonOnly";

      device = {
        name = "spotify-player";
        device_type = "computer";
        volume = 70;
        bitrate = 320;
        audio_cache = true;
        normalization = true;
        autoplay = false;
      };

      layout = {
        playback_window_position = "Top";
        playback_window_height = 6;
        library = {
          album_percent = 40;
          playlist_percent = 40;
        };
      };
    };

    # $XDG_CONFIG_HOME/spotify-player/keymap.toml (merged with defaults)
    keymaps = [
      {
        command = "NextTrack";
        key_sequence = "g n";
      }
      {
        command = "PreviousTrack";
        key_sequence = "g p";
      }
    ];

    actions = [
      {
        action = "ToggleLiked";
        key_sequence = "C-l";
        target = "PlayingTrack";
      }
    ];
  };

  # Headless player started with the graphical session. `-d` double-forks
  # (daemonize crate), hence Type=forking. Exposes MPRIS
  # (org.mpris.MediaPlayer2.spotify_player, used by `wayle media` and the bar)
  # and the CLI socket on 127.0.0.1:8080 for `spotify_player playback ...`.
  systemd.user.services.spotify-player = {
    Unit = {
      Description = "spotify-player streaming daemon";
      After = ["graphical-session.target" "pipewire.service" "sops-nix.service"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Type = "forking";
      ExecStart = "${pkgs.spotify-player}/bin/spotify_player -d";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
