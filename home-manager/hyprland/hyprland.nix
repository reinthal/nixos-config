{
  pkgs,
  lib,
  inputs,
  isNvidia ? false,
  ...
}: let
  hyprland-contrib = inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system};
in {
  home.packages =
    lib.optionals isNvidia [
      pkgs.egl-wayland
    ]
    ++ [
      hyprland-contrib.scratchpad
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
    # Pin legacy default; config below is hyprlang syntax, not lua.
    # HM flipped the default to "lua" for stateVersion >= 26.05.
    configType = "hyprlang";
    xwayland.enable = true;
    systemd.variables = ["--all"];

    settings = {
      monitor = [
        "eDP-1, preferred, 0x0,2"
        "HDMI-A-1, 3440x1440@75.05Hz,auto-up,1.33"
      ];

      # Fix pixelated extra screen
      xwayland = {
        force_zero_scaling = true;
      };

      env =
        [
          # Hyprland/WAYLAND
          "GDK_SCALE,2"
          # TODO 2025-03-01: https://discuss.cachyos.org/t/nautilus-stopped-working-overnight/3126/4
          # something is broken on wayland+hyrpland
          "GSK_RENDERER,ngl"
          "XCURSOR_SIZE,32"
          "GTK_THEME,Nord"
          "GDK_BACKEND,wayland,x11,*"
          "QT_QPA_PLATFORM,wayland;xcb"
          "CLUTTER_BACKEND,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"

          # Hint electron apps to use wayland
          "NIXOS_OZONE_WL,1"
        ]
        ++ lib.optionals isNvidia [
          "LIBVA_DRIVER_NAME,nvidia"
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        ];

      cursor = {};
      # Switchable keyboard layout
      input = {
        kb_layout = "us,se";
        kb_options = [
          "grp:alt_space_toggle"
        ];
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
        rounding = 10;
        inactive_opacity = 1;
        active_opacity = 1;
        dim_inactive = false;
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = "on";
          noise = 0.01;
          contrast = 0.9;
          brightness = 0.8;
          popups = true;
        };
      };
      workspace = let
        ws_monitor0 = [0 1 2 3];
        ws_monitor1 = [4 5 6 7];
        f = ws: monitor: "${ws}, monitor:${monitor}";
        g = handle: cmd: "special:${handle}, on-created-empty:${cmd}";
      in
        (map (i: f (toString i) "0") ws_monitor0) # half of the ws to monitor 0
        ++ (map (i: f (toString i) "1") ws_monitor1) # half of the ws to monitor 1
        ++ [
          (g "tasks" "chromium --app=https://linear.app/reinthal/team/REI/active")
          (g "llm" "claude-desktop")
          (g "toggl" "chromium --app=https://track.toggl.com/timer")
          (g "slack" "chromium --app=https://app.slack.com/client/T02MLJA4G/C06DHG3NJTS")
          (g "discord" "chromium --app=https://discord.com/channels/@me")
          (g "email" "chromium --app=https://mail.proton.me/")
          (g "code" "codium")
          (g "signal-desktop" "signal-desktop")
          (g "obsidian" "obsidian")
          (g "vault" "chromium --app=https://vault.reinthal.me")
        ];

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 5, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      windowrule = [
        "float on, match:class ^(org\\.gnome\\.Nautilus)$"
        "size 900 600, match:class ^(org\\.gnome\\.Nautilus)$"
      ];

      plugin = {
        overview = {
          centerAligned = true;
          hideTopLayers = true;
          hideOverlayLayers = true;
          showNewWorkspace = true;
          exitOnClick = true;
          exitOnSwitch = true;
          drawActiveWorkspace = true;
          reverseSwipe = true;
        };
      };
      exec-once = [
        "start"
        # waybar replaced by wayle (systemd user service, see gui/wayle.nix)
        "${pkgs.awww}/bin/awww-daemon"
        # mako replaced by wayle's notification daemon (see gui/wayle.nix)
      ];

      # Non-repeating, active while locked: mute toggles.
      bindl = [
        ",XF86AudioMute,     exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute,  exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      # Repeat on hold, active while locked: volume + brightness.
      bindle = [
        ",XF86AudioRaiseVolume,  exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86MonBrightnessUp,   exec, brightnessctl set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      bindm = [
        "SUPER, mouse:273, resizewindow"
        "SUPER, mouse:272, movewindow"
      ];

      bind = let
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
        mvfocus = binding "SUPER ALT" "movefocus";
        ws = binding "SUPER" "workspace";
        mvtows = binding "SUPER SHIFT" "movetoworkspace";
        arr = [1 2 3 4 5 6 7];
      in
        [
          "SUPER, Return, exec, ghostty"
          "SUPER, Space, exec, fuzzel"
          "SUPER SHIFT, C, exec, bzmenu -l fuzzel"
          "SUPER SHIFT, V, exec, iwmenu -l fuzzel"
          "SUPER SHIFT, B, exec, pwmenu -l fuzzel"
          "SUPER, slash, exec, hyprland-keybindings-menu"
          "SUPER SHIFT, T, exec, timer-bar menu"
          "SUPER, W, exec, firefox"
          "SUPER, D, exec, wayle notify dismiss-all"
          "SUPER SHIFT, D, exec, wayle notify dismiss-all"
          "SUPER, B, exec, awww-wallpaper"

          "SUPER, S, exec, scratchpad"
          "SUPER, r, exec, scratchpad -g -l"
          "CTRL SHIFT, s, exec, toggle-scratchpad"

          "SUPERSHIFT, S, exec, hyprshot -m region --clipboard-only"
          "ALT, Tab, focuscurrentorlast"
          "CTRL ALT, D, exit"
          "SUPER, Q, killactive"
          "SUPER, F, togglefloating"
          "SUPER, A, layoutmsg, togglesplit"
          "SUPER, G, fullscreen"
          "SUPER, P, togglespecialworkspace, vault"
          "CTRL SUPER,Q,exec,swaylock"
          "CTRL SUPER, G, exec, gamemode"
          "SUPER, O, togglespecialworkspace, obsidian"
          "SUPER, M, togglespecialworkspace, slack"
          "SUPER, N, togglespecialworkspace, discord"
          "SUPER, V, togglespecialworkspace, email"
          "SUPER, C, togglespecialworkspace, code"
          "SUPER, H, togglespecialworkspace, tasks"
          "SUPER, J, togglespecialworkspace, llm"
          "SUPER, K, togglespecialworkspace, signal-desktop"
          "SUPER, L, togglespecialworkspace, toggl"
          (mvfocus "k" "u")
          (mvfocus "j" "d")
          (mvfocus "l" "r")
          (mvfocus "h" "l")
          (ws "left" "e-1")
          (ws "right" "e+1")
          (mvtows "left" "e-1")
          (mvtows "right" "e+1")
        ]
        ++ (map (i: ws (toString i) (toString i)) arr)
        ++ (map (i: mvtows (toString i) (toString i)) arr);
    };
  };
}
