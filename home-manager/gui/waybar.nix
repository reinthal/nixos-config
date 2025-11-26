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
    modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
    modules-center = [ "sway/window" "custom/hello-from-waybar" ];
    modules-right = [ "mpd" "custom/mymodule#with-css-id" "temperature" ];

    "sway/workspaces" = {
      disable-scroll = true;
      all-outputs = true;
    };
    "custom/hello-from-waybar" = {
      format = "hello {}";
      max-length = 40;
      interval = "once";
      exec = pkgs.writeShellScript "hello-from-waybar" ''
        echo "from within waybar"
      '';
    };
  };
    };
  };
  home.packages = shell-dependencies;
}
