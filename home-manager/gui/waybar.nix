{
  inputs,
  pkgs,
  ...
}: let
marble = inputs.marble.packages.${pkgs.system}.default;
shell-dependencies = with pkgs; [
    dart-sass
    fd
    brightnessctl
    swww
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
