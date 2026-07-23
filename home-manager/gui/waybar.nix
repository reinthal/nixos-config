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
    local-pkgs.timer-bar
  ];
in {
  programs.waybar = {
    # Disabled in favour of wayle (see wayle.nix). Kept imported so its shell
    # tooling (slurp, pavucontrol, wl-clipboard, brightnessctl, ...) stays.
    enable = false;
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
        modules-right = ["custom/timer" "battery" "clock" "temperature" ];

        "custom/timer" = {
          exec = "${pkgs.local-pkgs.timer-bar}/bin/timer-bar status";
          return-type = "json";
          interval = 1;
          on-click = "${pkgs.local-pkgs.timer-bar}/bin/timer-bar menu";
          on-click-right = "${pkgs.local-pkgs.timer-bar}/bin/timer-bar stop";
          tooltip = true;
        };

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
