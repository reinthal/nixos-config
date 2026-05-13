{
  inputs,
  pkgs,
  ...
}: let
shell-dependencies = with pkgs; [
    dart-sass
    fd
    brightnessctl
    awww
    slurp
    wf-recorder
    wl-clipboard
    wayshot
    swappy
    pavucontrol
    networkmanager
    gtk3
    jq
  ];
in {
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = [
          "eDP-1"
          "HDMI-A-1"
          "DP-2"
        ];
        modules-left = [ "hyprland/workspaces" "wlr/taskbar" ];
        modules-right = ["battery" "clock" "temperature" ];
        
        battery = {
            format = "{capacity}% {icon}";
            format-icons = ["" "" "" "" ""];
        };
        clock = {
            format-alt =  "{:%a, %d. %b  %H:%M}";
        };

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
          all-outputs = true;
          sort-by-number = true;
          active-only = false;
        };
      };
    };
  };
  home.packages = shell-dependencies;
}
