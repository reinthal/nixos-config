{
  pkgs,
  lib,
  ...
}: {
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
    extraConfig = let
      modifier = "SUPER";
      modifier2 = "ALT";
    in
      lib.concatStrings [
        ''
          monitor=DP-1, 3456x2234, 0x0, 2
        ''
      ];
    settings = {
      "$mod" = "SUPER";
      bind =
        [
          "$mainMod, S, exec, rofi -show drun -show-icons"
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
