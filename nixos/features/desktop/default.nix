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
   [
    morewaita-icon-theme
    adwaita-icon-theme
    qogir-icon-theme
    # Image Viewer
    loupe
    # file system tool
    nautilus
    # disk utility
    baobab
    gnome-calendar
    gnome-system-monitor
    gnome-calculator

    # Wayland /  Hyprland
    mako
    libnotify
    wl-gammactl
    wl-clipboard
    wayshot
    rofi-wayland
    # sound control
    pavucontrol
    brightnessctl

    # wallpaper
    swww
  ] ++ (with pkgs.gnome; [
    gnome-boxes
    gnome-text-editor # webcam tool
    gnome-clocks
    gnome-software # for flatpak
    gnome-control-center
    gnome-weather
    
])
  ;

  environment.gnome.excludePackages = (with pkgs; [
  gnome-photos
  gnome-tour
  gedit # text editor
  cheese # webcam tool
  gnome-terminal
  evince # document viewer
  epiphany # web browser
  totem # video player
  geary # email reader
]) ++ (with pkgs.gnome; [
  gnome-music
  gnome-characters
  tali # poker game
  iagno # go game
  hitori # sudoku game
  atomix # puzzle game
]);
}
