{ ... }:

{
  # status bar for hyprland/wayland
  programs.waybar = {
    enable = true;
    settings = [
      {
        position = "top";
        include = [ "${./shared.json}" ];
        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [
          "custom/left-arrow-dark"
          "clock#2"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "tray"
          "custom/right-arrow-dark"
          "custom/right-arrow-light"
          "clock#3"
          "custom/right-arrow-dark"
        ];
        modules-right = [
          "custom/left-arrow-dark"
          "pulseaudio"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "memory"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "battery"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "hyprland/language"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "network"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
          "group/group-power"
          "custom/left-arrow-light"
          "custom/left-arrow-dark"
        ];
      }
    ];
    style = builtins.readFile ./style.css;
    systemd.enable = true;
  };
}