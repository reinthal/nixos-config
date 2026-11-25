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
  # Bind to a Lua helper from wm.lua (wm.*), rendered as a closure.
  call = fn: args: lua "function() wm.${fn}(${lib.concatMapStringsSep ", " toLua args}) end";
  focus = dsp "focus";
  moveWindow = dsp "window.move";

  # hl.bind(keys, dispatcher[, flags])
  bind = keys: dispatcher: {_args = [keys dispatcher];};
  bindWith = flags: keys: dispatcher: {_args = [keys dispatcher flags];};

  # Apps with a workspace of their own, in order: the first lives on workspace
  # `firstAppWorkspace`, the next on the one after, and so on. `key` jumps to
  # the workspace and starts `cfg.apps.<app>` there if it is empty.
  # Workspaces 1-5 belong to the main monitor and 6-10 to the secondary one
  # (see wm.lua).
  firstAppWorkspace = 11;
  appBinds = lib.imap0 (i: b: b // {workspace = firstAppWorkspace + i;}) [
    {
      key = "H";
      app = "tasks";
    }
    {
      key = "J";
      app = "llm";
    }
    {
      key = "K";
      app = "signal-desktop";
    }
    {
      key = "L";
      app = "toggl";
    }
    {
      key = "M";
      app = "slack";
    }
    {
      key = "N";
      app = "discord";
    }
    {
      key = "V";
      app = "email";
    }
    {
      key = "E";
      app = "calendar";
    }
    {
      key = "C";
      app = "code";
    }
    {
      key = "O";
      app = "obsidian";
    }
    {
      key = "P";
      app = "vault";
    }
  ];
in {
  options.local.hyprland = {
    # App handle -> command that fills its workspace when opened empty (see
    # appBinds). Hosts override single entries (see home-manager/framebook.nix).
    apps = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Apps that own a numbered workspace, keyed by handle.";
    };
    locker = lib.mkOption {
      type = lib.types.enum ["swaylock" "hyprlock"];
      default = "swaylock";
      description = ''
        Screen locker. Selects the package + config (swaylock.nix /
        hyprlock.nix, both gated on this) and the default lockCommand.
        Hosts override per device (framebook uses hyprlock; see
        home-manager/framebook.nix).
      '';
    };
    lockCommand = lib.mkOption {
      type = lib.types.str;
      description = "Command bound to CTRL + SUPER + Q. Defaults from `locker`.";
    };
  };

  config = {
    local.hyprland.lockCommand = lib.mkDefault (
      if cfg.locker == "hyprlock"
      then "pidof hyprlock || hyprlock"
      else "swaylock"
    );

    local.hyprland.apps = lib.mapAttrs (_: lib.mkDefault) {
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
        pkgs.local-pkgs.hyprland-window-switcher
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

          # Dell U3225QE: 31.5" 4K (~140 PPI) @ 120Hz. 1.25 divides 3840x2160
          # cleanly -> 3072x1728 logical, so no fractional-pixel blur.
          {
            output = "desc:Dell Inc. DELL U3225QE C4RDKJ4";
            mode = "3840x2160@120.00Hz";
            position = "auto-right";
            scale = 1.25;
          }

          {
            output = "desc:Acer Technologies CB342CK 0x00003726";
            mode = "3440x1440@75.05Hz";
            position = "auto-up";
            scale = 1;
          }

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
          # Don't auto-switch to HDR/wide-gamut on fullscreen: it forces a
          # modeset (screen blackout) and the 8-bit eDP-1 panel can't do it
          # properly ("wide color gamut is enabled but not in 10-bit mode").
          render = {
            cm_auto_hdr = 0;
          };
        };

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

        # The window switcher's list is redrawn on every Tab; animating it
        # would flicker.
        layer_rule = [
          {
            match.namespace = "^hyprland-window-switcher$";
            no_anim = true;
          }
        ];

        window_rule = [
          {
            match.class = "^(org\\.gnome\\.Nautilus)$";
            float = true;
            size = "900 600";
          }
        ];

        on = [
          {
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
          }
          # Put workspaces 1-5 on the main monitor and 6-10 on the secondary
          # one at login and whenever a display is plugged in.
          {_args = ["hyprland.start" (lua "function() wm.arrange_soon() end")];}
          {_args = ["monitor.added" (lua "function() wm.arrange_soon() end")];}
        ];

        bind = let
          # Non-repeating, active while locked: mute toggles.
          bindl = bindWith {locked = true;};
          # Repeat on hold, active while locked: volume + brightness.
          bindle = bindWith {
            locked = true;
            repeating = true;
          };
          bindm = bindWith {mouse = true;};
          arr = [1 2 3 4 5];
        in
          [
            (bindl "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
            (bindl "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

            # Media keys -> MPRIS via wayle (whatever player is active)
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
            # Tap opens the launcher (on release); held, it turns SUPER + 1-5
            # into the secondary monitor's workspaces 6-10 (wm.go / wm.send).
            (bind "SUPER + Space" (call "launcher_down" []))
            (bindWith {release = true;} "SUPER + Space" (call "launcher_up" ["fuzzel"]))
            (bind "SUPER + SHIFT + C" (exec "bzmenu -l fuzzel"))
            (bind "SUPER + SHIFT + V" (exec "iwmenu -l fuzzel"))
            (bind "SUPER + SHIFT + B" (exec "pwmenu -l fuzzel"))
            (bind "SUPER + slash" (exec "hyprland-keybindings-menu"))
            (bind "SUPER + SHIFT + T" (exec "timer-bar menu"))
            (bind "SUPER + W" (exec "firefox"))
            (bind "SUPER + D" (exec "wayle notify dismiss-all"))
            (bind "SUPER + SHIFT + D" (exec "wayle notify dismiss-all"))
            (bind "SUPER + B" (exec "awww-wallpaper"))

            (bind "SUPER + SHIFT + S" (exec "hyprshot -m region --clipboard-only"))
            (bind "ALT + Tab" (focus {last = true;}))
            # Window switcher: hold SUPER, Tab to move, release to focus
            # (wm.switch; the rest of its keys live in its submap in wm.lua).
            (bind "SUPER + Tab" (call "switch" [1]))
            (bind "SUPER + SHIFT + Tab" (call "switch" [(-1)]))
            (bind "CTRL + ALT + D" (dsp' "exit"))
            (bind "SUPER + Q" (dsp' "window.close"))
            (bind "SUPER + F" (dsp "window.float" {action = "toggle";}))
            (bind "SUPER + A" (dsp "layout" "togglesplit"))
            (bind "SUPER + G" (dsp' "window.fullscreen"))
            (bind "CTRL + SUPER + Q" (exec cfg.lockCommand))
            (bind "CTRL + SUPER + G" (exec "gamemode"))
            (bind "SUPER + ALT + K" (focus {direction = "up";}))
            (bind "SUPER + ALT + J" (focus {direction = "down";}))
            (bind "SUPER + ALT + L" (focus {direction = "right";}))
            (bind "SUPER + ALT + H" (focus {direction = "left";}))
            (bind "SUPER + left" (focus {workspace = "e-1";}))
            (bind "SUPER + right" (focus {workspace = "e+1";}))
            (bind "SUPER + SHIFT + left" (moveWindow {workspace = "e-1";}))
            (bind "SUPER + SHIFT + right" (moveWindow {workspace = "e+1";}))
          ]
          ++ (map (b: bind "SUPER + ${b.key}" (call "app" [b.workspace cfg.apps.${b.app}])) appBinds)
          ++ (map (i: bind "SUPER + ${toString i}" (call "go" [i])) arr)
          ++ (map (i: bind "SUPER + SHIFT + ${toString i}" (call "send" [i])) arr);
      };

      # Helpers behind the wm.* binds above. Globals, so the closures rendered
      # from `settings` can reach them.
      extraConfig = builtins.readFile ./wm.lua;
    };
  };
}
