{
  inputs,
  pkgs,
  ...
}: let  
marble = inputs.marble.packages.${pkgs.system}.default; 
shell-dependencies = with pkgs; [ 
    bun
    dart-sass
    fd
    brightnessctl
    swww
    matugen
    slurp
    wf-recorder
    wl-clipboard
    wayshot
    swappy
    hyprpicker
    pavucontrol
    networkmanager
    gtk3
  ];
in {
  home.packages = [marble] ++ shell-dependencies;
}
