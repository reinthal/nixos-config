{pkgs, inputs, ...}: {
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    xwayland.enable = true;
  };

  #xdg.portal = {
  #  enable = true;
  #  extraPortals = with pkgs; [
  #    xdg-desktop-portal-gtk
  #  ];
  #};
  # wayland-related
  security.polkit.enable = true;
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };
  environment.systemPackages = with pkgs;
  with gnome; [
    morewaita-icon-theme
    adwaita-icon-theme
    qogir-icon-theme
    loupe
    nautilus
    baobab
    gnome-text-editor
    gnome-calendar
    gnome-boxes
    gnome-system-monitor
    gnome-control-center
    gnome-weather
    gnome-calculator
    gnome-clocks
    gnome-software # for flatpak

    # Wayland /  Hyprland
    mako
    wl-gammactl
    wl-clipboard
    wayshot
    rofi-wayland
    # ?
    pavucontrol
    brightnessctl

    # wallpaper
    swww
  ];
}
