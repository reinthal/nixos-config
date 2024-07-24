{
  pkgs,
  lib,
  inputs,
  ...
}: let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.waybar}/bin/waybar &
    ${pkgs.swww}/bin/swww init &
      export XKB_DEFAULT_LAYOUT=us
      export XCURSOR_THEME=Qogir
    sleep 1

    ${pkgs.swww}/bin/swww img ${../img/landscape.png} &
  '';
in {
  home.packages = with pkgs; [
    # wayland
  ];
  programs = {
    waybar.enable = true;
  };
  services.mako = {
    enable = true;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    plugins = [
      pkgs.hyprlandPlugins.hyprbars
    ];
    extraConfig = let
      modifier = "SUPER";
      modifier2 = "ALT";
    in
      lib.concatStrings [
        ''
          monitor=DP-1, 3456x2234, 0x0, 2
          monitor=HDMI-A-1, highres,auto,2

          # Fix pixelated extra screen
          xwayland {
            force_zero_scaling = true
          }

          # toolkit-specific scale
          env = GDK_SCALE,2
          env = XCURSOR_SIZE,32
        ''
      ];
    settings = {
      # Switchable keyboard layout
      input = {
        kb_layout = "us,se";
        kb_options = "grp:alt_space_toggle";
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_use_r = true;
      };
      decoration = {
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
        hyprbars = {
          bar_color = "rgb(2a2a2a)";
          bar_height = 28;
          col_text = "rgba(ffffffdd)";
          bar_text_size = 11;
          bar_text_font = "Ubuntu Nerd Font";

          buttons = {
            button_size = 0;
            "col.maximize" = "rgba(ffffff11)";
            "col.close" = "rgba(ff111133)";
          };
        };
      };
      exec-once = ''${startupScript}/bin/start'';

      bindle = [
        ",XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bind = let
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
        mvfocus = binding "SUPER" "movefocus";
        ws = binding "SUPER" "workspace";
        resizeactive = binding "SUPER CTRL" "resizeactive";
        mvactive = binding "SUPER ALT" "moveactive";
        mvtows = binding "SUPER SHIFT" "movetoworkspace";
        arr = [1 2 3 4 5 6 7];
      in
        [
          "SUPER, Return, exec, kitty"
          "SUPER, mouse:273, movewindow"
          "SUPER, Space, exec, rofi -show drun -show-icons"
          "SUPER, W, exec, firefox"
          ", Print, exec, grimblast copy area"

          "ALT, Tab, focuscurrentorlast"
          "CTRL ALT, D, exit"
          "ALT, Q, killactive"
          "SUPER, F, togglefloating"
          "SUPER, G, fullscreen"
          "SUPER, O, fakefullscreen"
          "SUPER, P, togglesplit"
        ]
        ++ (
          # workspaces
          # binds SUPER + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "SUPER, ${ws}, workspace, ${toString (x + 1)}"
                "SUPER SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        );
    };
  };
}
