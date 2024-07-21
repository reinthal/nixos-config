{pkgs, ...}: 
{
    programs.hyprland.enable = true;
    # wayland-related
    security.polkit.enable = true;
}