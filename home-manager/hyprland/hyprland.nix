{
  pkgs,
  lib,
  inputs,
  ...
}: let
  is_nvidia = builtins.currentSystem == "x86_64-linux";
  hyprland-contrib = inputs.hyprland-contrib.packages.${pkgs.system};
  pyprland = inputs.pyprland.packages.${pkgs.system}.pyprland;
  marble = inputs.marble.packages.${pkgs.system}.default;
in {
  xdg = {
    configFile."marble/theme.json".source = ../dotfiles/marble/theme.json;
  };
  home.packages =
    lib.optionals is_nvidia [
      pkgs.egl-wayland
    ]
    ++ [
      hyprland-contrib.scratchpad
      marble
    ];
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
    xwayland.enable = true;
    systemd.variables = ["--all"];

    extraConfig = lib.concatStrings [
      ''
        monitor=eDP-1, 3456x2160, 0x0, 1.8
        #monitor=HDMI-A-1, 3440x1440@75.05Hz,auto-up,1.6
        monitor=HDMI-A-1, preferred,auto-right,1

        # Fix pixelated extra screen
        xwayland {
          force_zero_scaling = true
        }

        # toolkit-specific scale
      ''
    ];

    settings = {
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
        ++ lib.optionals is_nvidia [
          "AQ_DRM_DEVICES,/dev/dri/card1"
          "LIBVA_DRIVER_NAME,nvidia"
          "GBM_BACKEND,nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        ];

      cursor = {
        no_hardware_cursors = true;
      };
      # Switchable keyboard layout
      input = {
        kb_layout = "us,se";
        kb_options = [
          "grp:alt_space_toggle"
        ];
        repeat_delay = 200;
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_use_r = true;
      };
      general = {
        gaps_out = 5;
        layout = "dwindle";
        resize_on_border = true;
      };
      decoration = {
        rounding = 10;
        inactive_opacity = 0.70;
        active_opacity = 1.00;
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
      in
        (map (i: f (toString i) "0") ws_monitor0) # half of the ws to monitor 0
        ++ (map (i: f (toString i) "1") ws_monitor1) # half of the ws to monitor 1
        ++ [
          "special:tasks, on-created-empty:chromium --app=https://linear.app/reinthal/team/REI/active"
          "special:llm, on-created-empty:chromium --app=https://chat.platform.datadrivet.ai"
          "special:slack, on-created-empty:chromium --app=https://app.slack.com/client/T02MLJA4G/C06DHG3NJTS"
          "special:teams1, on-created-empty:teams-for-linux"
          "special:teams2, on-created-empty:flatpak run com.github.IsmaelMartinez.teams_for_linux"
          "special:email, on-created-empty:chromium --app=https://outlook.office.com"
          "special:code, on-created-empty:code"
          "special:signal-desktop, on-created-empty:signal-desktop"
        ];

      windowrulev2 = let
        f = regex: "float,title:^(${regex})$";
      in [
        (f "org.gnome.Calculator")
        (f "org.gnome.Nautilus")
        (f "pavucontrol")
        (f "nm-connection-editor")
        (f "blueberry.py")
        (f "org.gnome.Settings")
        (f "org.gnome.design.Palette")
        (f "Color Picker")
        (f "xdg-desktop-portal")
        (f "xdg-desktop-portal-gnome")
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
        "${pkgs.swww}/bin/swww-daemon"
        "start"
        "${pyprland}/bin/pypr --debug /tmp/pypr.log"
      ];

      bindle = [
        ",XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindm = [
        "SUPER, mouse:273, resizewindow"
        "SUPER, mouse:272, movewindow"
      ];

      bind = let
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
        mvfocus = binding "SUPER" "movefocus";
        ws = binding "SUPER" "workspace";
        mvtows = binding "SUPER SHIFT" "movetoworkspace";
        e = "exec, marble";
        arr = [1 2 3 4 5 6 7];
      in
        [
          "SUPER, Return, exec, kitty"
          "SUPER, Space, exec, rofi -show drun"
          "SUPER, W, exec, zen"
          # Pypr
          "SUPER, D, exec, pypr toggle term"

          "SUPER, S, exec, scratchpad"
          "SUPER, r, exec, scratchpad -g -l"
          "CTRL SHIFT, s, exec, toggle-scratchpad"

          "SUPERSHIFT, S, exec, hyprshot -m region --clipboard-only"
          "ALT, Tab, focuscurrentorlast"
          "CTRL ALT, D, exit"
          "SUPER, Q, killactive"
          "SUPER, F, togglefloating"
          "SUPER, G, fullscreen"
          "SUPER, P, togglesplit"
          "CTRL SUPER,Q,exec,swaylock"
          "CTRL SUPER, G, exec, gamemode"

          "SUPER, M, togglespecialworkspace, slack"
          "SUPER, N, togglespecialworkspace, teams1"
          "SUPER, B, togglespecialworkspace, teams2"
          "SUPER, V, togglespecialworkspace, email"
          "SUPER, C, togglespecialworkspace, code"
          "SUPER, K, togglespecialworkspace, signal-desktop"
          "SUPER, J, togglespecialworkspace, llm"
          "SUPER, H, togglespecialworkspace, tasks"

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
