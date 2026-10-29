{
  config,
  pkgs,
  lib,
  isNvidia ? false,
  ...
}: let
  cfg = config.local.hyprland;

  lua = lib.generators.mkLuaInline;
  toLua = lib.generators.toLua {multiline = false;};

  # Dispatchers (hl.dsp.*), rendered as raw Lua expressions.
  dsp = name: arg: lua "hl.dsp.${name}(${toLua arg})";
  dsp' = name: lua "hl.dsp.${name}()";
  exec = dsp "exec_cmd";
  toggleSpecial = dsp "workspace.toggle_special";
  focus = dsp "focus";
  moveWindow = dsp "window.move";

  # hl.bind(keys, dispatcher[, flags])
  bind = keys: dispatcher: {_args = [keys dispatcher];};
  bindWith = flags: keys: dispatcher: {_args = [keys dispatcher flags];};
in {
  options.local.hyprland = {
    # Special workspace handle -> command that fills it when first opened.
    # Hosts override single entries (see home-manager/framebook.nix).
    scratchpads = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Apps opened by special workspaces, keyed by handle.";
    };
    lockCommand = lib.mkOption {
      type = lib.types.str;
      default = "swaylock";
      description = "Command bound to CTRL + SUPER + Q.";
    };
    # spotify-search / spotify-queue talk to the spotify-player daemon
    # (cli/spotify-player.nix); hosts on the native client turn them off.
    spotifyPlayerBinds = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Bind the spotify-player fuzzel search and queue menus.";
    };
  };

  config = {
    local.hyprland.scratchpads = lib.mapAttrs (_: lib.mkDefault) {
      tasks = "chromium --app=https://linear.app/reinthal/team/REI/active";
      llm = "claude-desktop";
      toggl = "chromium --app=https://track.toggl.com/timer";
      slack = "slacky";
      discord = "vesktop";
      email = "chromium --app=https://mail.proton.me/";
      code = "codium";
      signal-desktop = "signal-desktop";
      obsidian = "obsidian";
      vault = "chromium --app=https://vault.reinthal.me";
      calendar = "chromium --app=https://calendar.proton.me/u/0/";
    };

    home.packages =
      lib.optionals isNvidia [
        pkgs.egl-wayland
      ]
      ++ [
        pkgs.local-pkgs.hyprland-keybindings-menu
      ]
      # mako removed: its D-Bus activation file (fr.emersion.mako.service) would
      # auto-start mako on the first notification and steal
      # org.freedesktop.Notifications from wayle's daemon. libnotify stays for
      # notify-send. See gui/wayle.nix.
      ++ (with pkgs; [hyprshot libnotify]);
    systemd.user.services."hyprctl-reload" = {
      Unit = {
        Description = "Reload Hyprland to fix sizing of borders after login.";
        After = ["xdg-desktop-portal-hyprland.service" "graphical-session.target"];
        Requires = ["xdg-desktop-portal-hyprland.service"];
        # graphical-session.target is also reached by the GNOME session on hosts
        # that offer both (framebook); there is no hyprctl socket there.
        ConditionEnvironment = "!XDG_CURRENT_DESKTOP=GNOME";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash 'hyprctl-reload'";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
    wayland.windowManager.hyprland = {
      enable = true;
      # Lua config (~/.config/hypr/hyprland.lua). Each attribute in `settings`
      # renders as an `hl.<name>(...)` call; lists render one call per element.
      configType = "lua";
      xwayland.enable = true;
      systemd.variables = ["--all"];

      settings = {
        monitor = [
          {
            output = "eDP-1";
            mode = "preferred";
            position = "0x0";
            scale = 2;
          }
          # Acer ultrawide, matched by description (stable across ports).
          # Get desc for new screens with: hyprctl monitors all
          {
            output = "desc:Acer Technologies CB342CK 0x00003726";
            mode = "3440x1440@75.05Hz";
            position = "auto-up";
            scale = 1;
          }
          # Asahi's dcp driver exposes no EDID make/model, so desc: never matches
          # on nixbook — match the ultrawide by port there instead.
          {
            output = "DP-1";
            mode = "3440x1440@75.05Hz";
            position = "auto-right";
            scale = 1.25;
          }
          # Fallback for any monitor without an explicit rule (the other screen).
          {
            output = "";
            mode = "2560x1440@120.00Hz";
            position = "auto-right";
            scale = 1;
          }
        ];

        env =
          lib.mapAttrsToList (name: value: {_args = [name value];})
          ({
              # Hyprland/WAYLAND
              GDK_SCALE = "2";
              # TODO 2025-03-01: https://discuss.cachyos.org/t/nautilus-stopped-working-overnight/3126/4
              # something is broken on wayland+hyrpland
              GSK_RENDERER = "ngl";
              XCURSOR_SIZE = "32";
              GTK_THEME = "Nord";
              GDK_BACKEND = "wayland,x11,*";
              QT_QPA_PLATFORM = "wayland;xcb";
              CLUTTER_BACKEND = "wayland";
              XDG_SESSION_DESKTOP = "Hyprland";
              XDG_CURRENT_DESKTOP = "Hyprland";
              XDG_SESSION_TYPE = "wayland";

              # Hint electron apps to use wayland
              NIXOS_OZONE_WL = "1";
            }
            // lib.optionalAttrs isNvidia {
              LIBVA_DRIVER_NAME = "nvidia";
              GBM_BACKEND = "nvidia-drm";
              __GLX_VENDOR_LIBRARY_NAME = "nvidia";
            });

        config = {
          # Fix pixelated extra screen
          xwayland = {
            force_zero_scaling = true;
          };

          # Switchable keyboard layout
          input = {
            kb_layout = "us,se";
            kb_options = "grp:alt_space_toggle";
            repeat_delay = 200;
          };

          general = {
            gaps_out = 5;
            layout = "dwindle";
            resize_on_border = true;
          };
          dwindle = {
            preserve_split = true;
          };
          decoration = {
            rounding = 5;
            inactive_opacity = 1;
            active_opacity = 1;
            dim_inactive = false;
            blur = {
              enabled = true;
              size = 8;
              passes = 3;
              new_optimizations = true;
              noise = 0.01;
              contrast = 0.9;
              brightness = 0.8;
              popups = true;
            };
          };
          animations = {
            enabled = true;
          };
        };

        workspace_rule = let
          ws_monitor0 = [0 1 2 3];
          ws_monitor1 = [4 5 6 7];
          f = monitor: ws: {
            workspace = toString ws;
            inherit monitor;
          };
          g = handle: cmd: {
            workspace = "special:${handle}";
            on_created_empty = cmd;
          };
        in
          (map (f "0") ws_monitor0) # half of the ws to monitor 0
          ++ (map (f "1") ws_monitor1) # half of the ws to monitor 1
          ++ lib.mapAttrsToList g cfg.scratchpads;

        curve = {
          _args = [
            "myBezier"
            {
              type = "bezier";
              points = [[0.05 0.9] [0.1 1.05]];
            }
          ];
        };
        animation = let
          anim = leaf: speed: bezier: {
            inherit leaf speed bezier;
            enabled = true;
          };
        in [
          (anim "windows" 5 "myBezier")
          (anim "windowsOut" 7 "default" // {style = "popin 80%";})
          (anim "border" 10 "default")
          (anim "fade" 7 "default")
          (anim "workspaces" 6 "default")
        ];

        window_rule = [
          {
            match.class = "^(org\\.gnome\\.Nautilus)$";
            float = true;
            size = "900 600";
          }
        ];

        on = {
          _args = [
            "hyprland.start"
            # waybar and mako replaced by wayle (systemd user service, see
            # gui/wayle.nix)
            (lua ''
              function()
                hl.exec_cmd("start")
                hl.exec_cmd("${pkgs.awww}/bin/awww-daemon")
              end'')
          ];
        };

        bind = let
          # Non-repeating, active while locked: mute toggles.
          bindl = bindWith {locked = true;};
          # Repeat on hold, active while locked: volume + brightness.
          bindle = bindWith {
            locked = true;
            repeating = true;
          };
          bindm = bindWith {mouse = true;};
          arr = [1 2 3 4 5 6 7];
        in
          [
            (bindl "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
            (bindl "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

            # Media keys -> MPRIS via wayle (spotify-player daemon, or whatever is active)
            (bindl "XF86AudioPlay" (exec "wayle media play-pause"))
            (bindl "XF86AudioPause" (exec "wayle media play-pause"))
            (bindl "XF86AudioNext" (exec "wayle media next"))
            (bindl "XF86AudioPrev" (exec "wayle media previous"))

            (bindle "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"))
            (bindle "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
            (bindle "XF86MonBrightnessUp" (exec "brightnessctl set 5%+"))
            (bindle "XF86MonBrightnessDown" (exec "brightnessctl set 5%-"))

            (bindm "SUPER + mouse:273" (dsp' "window.resize"))
            (bindm "SUPER + mouse:272" (dsp' "window.drag"))

            (bind "SUPER + Return" (exec "ghostty"))
            (bind "SUPER + Space" (exec "fuzzel"))
            (bind "SUPER + SHIFT + C" (exec "bzmenu -l fuzzel"))
            (bind "SUPER + SHIFT + V" (exec "iwmenu -l fuzzel"))
            (bind "SUPER + SHIFT + B" (exec "pwmenu -l fuzzel"))
            (bind "SUPER + slash" (exec "hyprland-keybindings-menu"))
            (bind "SUPER + SHIFT + T" (exec "timer-bar menu"))
            (bind "SUPER + W" (exec "firefox"))
            (bind "SUPER + E" (toggleSpecial "calendar"))
            (bind "SUPER + D" (exec "wayle notify dismiss-all"))
            (bind "SUPER + SHIFT + D" (exec "wayle notify dismiss-all"))
            (bind "SUPER + B" (exec "awww-wallpaper"))

            (bind "SUPER + SHIFT + S" (exec "hyprshot -m region --clipboard-only"))
            (bind "ALT + Tab" (focus {last = true;}))
            (bind "CTRL + ALT + D" (dsp' "exit"))
            (bind "SUPER + Q" (dsp' "window.close"))
            (bind "SUPER + F" (dsp "window.float" {action = "toggle";}))
            (bind "SUPER + A" (dsp "layout" "togglesplit"))
            (bind "SUPER + G" (dsp' "window.fullscreen"))
            (bind "SUPER + P" (toggleSpecial "vault"))
            (bind "CTRL + SUPER + Q" (exec cfg.lockCommand))
            (bind "CTRL + SUPER + G" (exec "gamemode"))
            (bind "SUPER + O" (toggleSpecial "obsidian"))
            (bind "SUPER + M" (toggleSpecial "slack"))
            (bind "SUPER + N" (toggleSpecial "discord"))
            (bind "SUPER + V" (toggleSpecial "email"))
            (bind "SUPER + C" (toggleSpecial "code"))
            (bind "SUPER + H" (toggleSpecial "tasks"))
            (bind "SUPER + J" (toggleSpecial "llm"))
            (bind "SUPER + K" (toggleSpecial "signal-desktop"))
            (bind "SUPER + L" (toggleSpecial "toggl"))
            (bind "SUPER + ALT + K" (focus {direction = "up";}))
            (bind "SUPER + ALT + J" (focus {direction = "down";}))
            (bind "SUPER + ALT + L" (focus {direction = "right";}))
            (bind "SUPER + ALT + H" (focus {direction = "left";}))
            (bind "SUPER + left" (focus {workspace = "e-1";}))
            (bind "SUPER + right" (focus {workspace = "e+1";}))
            (bind "SUPER + SHIFT + left" (moveWindow {workspace = "e-1";}))
            (bind "SUPER + SHIFT + right" (moveWindow {workspace = "e+1";}))
          ]
          ++ lib.optionals cfg.spotifyPlayerBinds [
            (bind "CTRL + SHIFT + Space" (exec "spotify-search"))
            (bind "SUPER + SHIFT + Space" (exec "spotify-queue"))
          ]
          ++ (map (i: bind "SUPER + ${toString i}" (focus {workspace = i;})) arr)
          ++ (map (i: bind "SUPER + SHIFT + ${toString i}" (moveWindow {workspace = i;})) arr);
      };
    };
  };
}
