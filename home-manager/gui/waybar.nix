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
    mako
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
        modules-right = ["custom/notification" "battery" "clock" "temperature" ];
        
        battery = {
            format = "{capacity}% {icon}";
            format-icons = ["" "" "" "" ""];
        };
        clock = {
            format-alt =  "{:%a, %d. %b  %H:%M}";
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification = "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which makoctl";
          exec = "mako-waybar";
          on-click = "${pkgs.mako}/bin/makoctl dismiss";
          on-click-right = "${pkgs.mako}/bin/makoctl dismiss -a";
          interval = 5;
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
