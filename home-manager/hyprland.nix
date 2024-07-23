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
      pkgs.hyprlandPlugins.borders-plus-plus
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

          # Switchable keyboard layout
          input {
            kb_layout = us,se
            kb_options = grp:alt_space_toggle
          }
        ''
      ];
    settings = {
      "plugin:borders-plus-plus" = {
        add_borders = 1; # 0 - 9

        # you can add up to 9 borders
        "col.border_1" = "rgb(ffffff)";
        "col.border_2" = "rgb(2222ff)";

        # -1 means "default" as in the one defined in general:border_size
        border_size_1 = 10;
        border_size_2 = -1;

        # makes outer edges match rounding of the parent. Turn on / off to better understand. Default = on.
        natural_rounding = "yes";
      };
      exec-once = ''${startupScript}/bin/start'';
      "$mod" = "SUPER";
      bind =
        [
          "$mod, Return, exec, kitty"
          "$mod, mouse:1, movewindow"
          "$mod, Space, exec, rofi -show drun -show-icons"
          "$mod, F, exec, firefox"
          ", Print, exec, grimblast copy area"
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        );
    };
  };
}
