{
  pkgs,
  inputs,
  ...
}: {
  services = {
    flatpak.enable = true;
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    xwayland.enable = true;
  };

  systemd.services.flatpak-repo = {
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  #xdg.portal = {
  #  enable = true;
  #  extraPortals = with pkgs; [
  #    xdg-desktop-portal-gtk
  #  ];
  #};
  # wayland-related
  security.polkit.enable = true;
  environment.systemPackages = with pkgs; [
    morewaita-icon-theme
    adwaita-icon-theme
    qogir-icon-theme
    # Image Viewer
    loupe
    brave

    # file system tool
    nautilus
    # disk utility
    baobab
    gnome-calendar
    gnome-system-monitor
    gnome-calculator
    gnome-tweaks
    wireshark
    # Wayland /  Hyprland
    libnotify
    wl-gammactl
    rofi-wayland
    gnome-boxes
    gnome-text-editor # webcam tool
    gnome-clocks
    gnome-software # for flatpak
    gnome-control-center
    gnome-weather
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gedit # text editor
    cheese # webcam tool
    gnome-terminal
    evince # document viewer
    epiphany # web browser
    totem # video player
    gnome-music
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
    gnome-characters
  ];
}
