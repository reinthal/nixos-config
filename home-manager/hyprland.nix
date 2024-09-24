{
  pkgs,
  lib,
  inputs,
  ...
}: let
  is_nvidia = builtins.currentSystem == "x86_64-linux";
in {
  home.packages = with pkgs;
    lib.optionals is_nvidia [
      egl-wayland
    ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    extraConfig = lib.concatStrings [
      ''
        monitor=eDP-1, 3456x2160, 0x0, 1.8
        #monitor=HDMI-A-1, 3440x1440@75.05Hz,auto-right,1.6
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
        repeat_delay = 220;
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_use_r = true;
      };

      decoration = {
        rounding = 10;
        inactive_opacity = 0.70;
        active_opacity = 0.80;
        drop_shadow = "yes";
        shadow_range = 8;
        shadow_render_power = 2;
        "col.shadow" = "rgba(00000044)";

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
        ++ (map (i: f (toString i) "1") ws_monitor1); # half of the ws to monitor 1

      windowrulev2 = let
        move_to_monitor = monitor_id: regex: "monitor ${monitor_id}, title:^(.*)(${regex})$";
      in [
        (move_to_monitor
          "0"
          "Microsoft Teams|Teams for Linux")
        (
          move_to_monitor "0" "Signal"
        )
        (move_to_monitor "0" "Brave")
      ];
      windowrule = let
        f = regex: "float, ^(${regex})$";
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
        (f "com.github.Aylur.ags")
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
      exec-once = ''start'';

      general = {
        layout = "dwindle";
        resize_on_border = true;
      };

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
        e = "exec, ags -b hypr";
        arr = [1 2 3 4 5 6 7];
      in
        [
          "SUPER, Tab, ${e} -t overview"
          "SUPER, Return, exec, kitty"
          "SUPER, Space, ${e} -t launcher"
          "SUPER, W, exec, firefox"

          "SUPER, S, exec, hyprshot -m region --clipboard-only"
          "ALT, Tab, focuscurrentorlast"
          "CTRL ALT, D, exit"
          "SUPER, Q, killactive"
          "SUPER, F, togglefloating"
          "SUPER, G, fullscreen"
          "SUPER, P, togglesplit"
          "CTRL SUPER,Q,exec,hyprlock"
          "CTRL SUPER, G, exec, gamemode"

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
